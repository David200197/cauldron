<?php
	/* Copyright (c) by Hugo Leisink <hugo@leisink.net>
	 * This file is part of the Banshee PHP framework
	 * https://www.banshee-php.org/
	 *
	 * Licensed under The MIT License
	 */

	class vault_user_model extends Banshee\model {
		private function access_allowed_for_non_admin($user) {
			if (is_array($user["roles"])) {
				if (in_array(ADMIN_ROLE_ID, $user["roles"])) {
					return false;
				}
			}

			if ($user["organisation_id"] != $this->user->organisation_id) {
				return false;
			}

			return true;
		}

		public function count_users() {
			$query = "select count(*) as count from users ".
				($this->user->is_admin ? "" : "where organisation_id=%d ").
				"order by username";

			if (($result = $this->db->execute($query, $this->user->organisation_id)) == false) {
				return false;
			}

			return $result[0]["count"];
		}

		public function get_users($order, $offset, $limit) {
			$query = "select * from users ";
			$args = array();
			if ($this->user->is_admin == false) {
				$query .= "where organisation_id=%d ";
				array_push($args, $this->user->organisation_id);
			}

			if (empty($_SESSION["user_search"]) == false) {
				$search_columns = array("username", "fullname", "email");
				foreach ($search_columns as $i => $column) {
					$search_columns[$i] = $column." like %s";
					array_push($args, "%".$_SESSION["user_search"]."%");
				}
				$query .= " having (".implode(" or ", $search_columns).")";
			}

			$query .= " order by %S,%S";
			array_push($args, $order);

			if (empty($_SESSION["user_search"])) {
				$query .= " limit %d,%d";
				array_push($args, $offset, $limit);
			};

			if (($users = $this->db->execute($query, $args)) === false) {
				return false;
			}

			$query = "select * from user_role where user_id=%d and role_id=%d";
			foreach ($users as $i => $user) {
				if (($role = $this->db->execute($query, $user["id"], ADMIN_ROLE_ID)) === false) {
					return false;
				}
				$users[$i]["is_admin"] = count($role) > 0;
			}

			return $users;
		}

		public function get_user($user_id) {
			static $users = array();

			if (isset($users[$user_id])) {
				return $users[$user_id];
			}

			if (($user = $this->db->entry("users", $user_id)) == false) {
				$this->user->log_action("requested non-existing user %s", $user_id);
				return false;
			}

			$query = "select role_id from user_role where user_id=%d";
			if (($roles = $this->db->execute($query, $user_id)) === false) {
				return false;
			}

			$user["roles"] = array();
			foreach ($roles as $role) {
				array_push($user["roles"], $role["role_id"]);
			}

			if ($this->user->is_admin == false) {
				if ($this->access_allowed_for_non_admin($user) == false) {
					$this->user->log_action("unauthorized view attempt of user %d", $user["id"]);
					return false;
				}
			}

			$users[$user_id] = $user;

			return $user;
		}

		public function get_username($user_id) {
			if (($user = $this->db->entry("users", $user_id)) == false) {
				return false;
			}

			return $user["username"];
		}

		public function get_organisations() {
			$query = "select * from organisations order by name";

			return $this->db->execute($query);
		}

		public function get_roles() {
			$query = "select * from roles";
			if ($this->user->is_admin == false) {
				$query .= " where non_admins=%d";
			}
			$query .= " order by name";

			return $this->db->execute($query, YES);
		}

		public function save_okay($user) {
			$result = true;

			if (isset($user["id"])) {
				if (($current = $this->get_user($user["id"])) == false) {
					$this->view->add_message("User not found.");
					return false;
				}

				/* Non-admins cannot edit admins
				 */
				if ($this->user->is_admin == false) {
					if ($this->access_allowed_for_non_admin($current) == false) {
						$this->view->add_message("User not found.");
						$this->user->log_action("unauthorized update attempt of user %d", $user["id"]);
						return false;
					}
				}
			}

			/* Check username
			 */
			if (($user["username"] == "") || (trim($user["fullname"]) == "")) {
				$this->view->add_message("The username and full name cannot be empty.");
				$result = false;
			} else if (valid_input($user["username"], VALIDATE_NONCAPITALS.VALIDATE_NUMBERS."@.-") == false) {
				$this->view->add_message("Invalid characters in username. Use only lowercase characters or an e-mail address.");
				$result = false;
			} else if (($check = $this->db->entry("users", $user["username"], "username")) === false) {
				$this->view->add_message("Database error.");
				$result = false;
			} else if ($check != false) {
				if ($check["id"] != ($user["id"] ?? null)) {
					$this->view->add_message("Username already exists.");
					$result = false;
				}
			}

			/* Check password
			 */
			if (isset($user["id"]) == false) {
				if (($user["password"] == "") && is_false($user["generate"] ?? false)) {
					$this->view->add_message("Fill in the password or let Cauldron VTT generate one.");
					$result = false;
				}
			}

			/* Check e-mail
			 */
			if (valid_email($user["email"]) == false) {
				$this->view->add_message("Invalid e-mail address.");
				$result = false;
			} else if (($check = $this->db->entry("users", $user["email"], "email")) != false) {
				if ($check["id"] != ($user["id"] ?? null)) {
					$this->view->add_message("E-mail address already exists.");
					$result = false;
				}
			}

			/* Check certificate serial
			 */
			if (valid_input($user["cert_serial"] ?? null, VALIDATE_NUMBERS) == false) {
				$this->view->add_message("The certificate serial must be a number.");
				$result = false;
			}

			/* Check authenticator secret
			 */
			if (is_true(USE_AUTHENTICATOR)) {
				if ((strlen($user["authenticator_secret"]) > 0) && ($user["authenticator_secret"] != str_repeat("*", 16))) {
					if (valid_input($user["authenticator_secret"], Banshee\authenticator::BASE32_CHARS, 16) == false) {
						$this->view->add_message("Invalid authenticator secret.");
						$result = false;
					}
				}
			}

			return $result;
		}

		private function assign_roles_to_user($user) {
			if ($this->user->is_admin == false) {
				if (($roles = $this->get_roles()) === false) {
					return false;
				}

				$allowed_roles = array();
				foreach ($roles as $role) {
					array_push($allowed_roles, (int)$role["id"]);
				}
			}

			if ($this->db->query("delete from user_role where user_id=%d", $user["id"]) == false) {
				return false;
			}

			if (is_array($user["roles"]) == false) {
				return true;
			}

			foreach ($user["roles"] as $role_id) {
				if ($this->user->is_admin == false) {
					if ($role_id == ADMIN_ROLE_ID) {
						$this->user->log_action("unauthorized admininstrator role assign attempt to user %d", $user["id"]);
						continue;
					}
					if (in_array($role_id, $allowed_roles) == false) {
						$this->user->log_action("unauthorized non-admin role (%d) assign attempt to user %d", $role_id, $user["id"]);
						continue;
					}
				}

				if ($this->db->query("insert into user_role values (%d, %d)", $user["id"], $role_id) == false) {
					return false;
				}
			}

			return true;
		}

		public function create_user($user, $register = false) {
			$keys = array("id", "organisation_id", "username", "password", "one_time_key", "cert_serial", "status", "authenticator_secret", "fullname", "email", "keyboard");

			$user["id"] = null;
			$user["username"] = strtolower($user["username"]);
			$user["password"] = password_hash($user["password"], PASSWORD_ALGORITHM);
			$user["one_time_key"] = null;
			$user["keyboard"] = 0;

			if (($this->user->is_admin == false) && ($register == false)) {
				$user["organisation_id"] = $this->user->organisation_id;
			}

			if (($user["cert_serial"] ?? "") == "") {
				$user["cert_serial"] = null;
			}

			if (trim($user["authenticator_secret"] ?? "") == "") {
				$user["authenticator_secret"] = null;
			}

			if ($this->db->query("begin") == false) {
				return false;
			}

			if ($this->db->insert("users", $user, $keys) === false) {
				$this->db->query("rollback");
				return false;
			}
			$user["id"] = $this->db->last_insert_id;

			if ($this->assign_roles_to_user($user) == false) {
				$this->db->query("rollback");
				return false;
			}

			if (module_exists("forum")) {
				$data = array("user_id" => $user["id"], "forum_topic_id" => null);
				$this->db->insert("forum_last_view", $data);
			}

			return $this->db->query("commit") != false;
		}

		public function update_user($user) {
			$keys = array("username", "fullname", "email", "cert_serial");

			$user["username"] = strtolower($user["username"]);

			if ($user["password"] != "") {
				array_push($keys, "password");
				$user["password"] = password_hash($user["password"], PASSWORD_ALGORITHM);
			}

			if ($this->user->is_admin) {
				array_push($keys, "organisation_id");
			}

			if (is_array($user["roles"] ?? null) == false) {
				$user["roles"] = array();
			}

			if ($this->user->id != $user["id"]) {
				array_push($keys, "status");
			} else if (($current = $this->get_user($user["id"])) == false) {
				return false;
			} else {
				if (in_array(ADMIN_ROLE_ID, $current["roles"]) && (in_array(ADMIN_ROLE_ID, $user["roles"]) == false)) {
					array_unshift($user["roles"], ADMIN_ROLE_ID);
				}

				if (in_array(USER_MAINTAINER_ROLE_ID, $current["roles"]) && (in_array(USER_MAINTAINER_ROLE_ID, $user["roles"]) == false)) {
					array_unshift($user["roles"], USER_MAINTAINER_ROLE_ID);
				}
			}

			if (($user["cert_serial"] ?? "") == "") {
				$user["cert_serial"] = null;
			}

			if (is_true(USE_AUTHENTICATOR)) {
				if ($user["authenticator_secret"] != str_repeat("*", 16)) {
					array_push($keys, "authenticator_secret");
					if (trim($user["authenticator_secret"]) == "") {
						$user["authenticator_secret"] = null;
					}
				}
			}

			if ($this->db->query("begin") == false) {
				return false;
			}

			if ($this->db->update("users", $user["id"], $user, $keys) === false) {
				$this->db->query("rollback");
				return false;
			}

			if ($this->assign_roles_to_user($user) == false) {
				$this->db->query("rollback");
				return false;
			}

			if ($this->user->id != $user["id"]) {
				if ($user["status"] == USER_STATUS_DISABLED) {
					$this->db->query("delete from sessions where user_id=%d", $user["id"]);
				}
			}

			return $this->db->query("commit") != false;
		}

		public function delete_okay($user_id) {
			$result = true;

			if ($user_id == $this->user->id) {
				$this->view->add_message("You are not allowed to delete your own account.");
				$result = false;
			}

			$query = "select count(*) as count from adventures where dm_id=%d";
			if (($adventures = $this->db->execute($query, $user_id)) == false) {
				$this->view->add_message("Database error.");
				$result = false;
			} else if ($adventures[0]["count"] > 0) {
				$this->view->add_message("This account contains adventures.");
				$result = false;
			}

			if ($this->user->is_admin == false) {
				if (($current = $this->get_user($user_id)) == false) {
					$this->view->add_message("User not found.");
					$result = false;
				}

				if ($this->access_allowed_for_non_admin($current) == false) {
					$this->user->log_action("unauthorized delete attempt of user %d", $user_id);
					$this->view->add_message("You are not allowed to delete this user.");
					$result = false;
				}
			}

			return $result;
		}

		public function delete_user($user_id) {
			$query = "select resources_key from organisations o, users u ".
			         "where o.id=u.organisation_id and u.id=%d";
			if (($result = $this->db->execute($query, $user_id)) == false) {
				return false;
			}
			$resources_key = $result[0]["resources_key"];

			$queries = array();

			$query = "select id, extension from characters where user_id=%d";
			if (($characters = $this->db->execute($query, $user_id)) === false) {
				$this->view->add_message("Database error.");
				return false;
			}

			$query = "select i.* from character_icons i, characters c ".
			         "where i.character_id=c.id and c.user_id=%d";
			if (($alternates = $this->db->execute($query, $user_id)) === false) {
				return false;
			}

			foreach ($characters as $character) {
				array_push($queries, array("delete from map_character where character_id=%d", $character["id"]));
				array_push($queries, array("delete from adventure_character where character_id=%d", $character["id"]));
				array_push($queries, array("delete from character_weapons where character_id=%d", $character["id"]));
				array_push($queries, array("delete from character_icons where character_id=%d", $character["id"]));
				array_push($queries, array("delete from characters where id=%d", $character["id"]));
			}

			array_push($queries,
				array("update journal set user_id=null where user_id=%d", $user_id),
				array("delete from custom_dice where user_id=%d", $user_id),
				array("delete from agenda where user_id=%d", $user_id),
				array("delete from sessions where user_id=%d", $user_id),
				array("delete from user_role where user_id=%d", $user_id),
				array("delete from users where id=%d", $user_id));

			if ($this->db->transaction($queries) === false) {
				return false;
			}

			foreach ($characters as $character) {
				$filename = "resources/".$resources_key."/characters/".$character["id"].".".$character["extension"];
				if (file_exists($filename)) {
					unlink($filename);
				}
			}

            foreach ($alternates as $alternate) {
                $filename = "resources/".$resources_key."/characters/".$alternate["character_id"]."_".$alternate["id"].".".$alternate["extension"];
                if (file_exists($filename)) {
                	unlink($filename);
                }
            }

			return true;
		}

		public function send_notification($user) {
			if (isset($user["id"]) == false) {
				$type = "created";
			} else {
				$type = "updated";
			}

			if (($message = file_get_contents("../extra/account_".$type.".txt")) === false) {
				return;
			}

			$replace = array(
				"USERNAME" => $user["username"],
				"PASSWORD" => $user["password"],
				"FULLNAME" => $user["fullname"],
				"HOSTNAME" => $_SERVER["SERVER_NAME"],
				"PROTOCOL" => $_SERVER["HTTP_SCHEME"],
				"TITLE"    => $this->settings->head_title);

			$email = new cauldron_email("Account ".$type." at ".$_SERVER["SERVER_NAME"], $this->settings->webmaster_email);
			$email->set_message_fields($replace);
			$email->message($message);

			return $email->send($user["email"], $user["fullname"]);
		}
	}
?>
