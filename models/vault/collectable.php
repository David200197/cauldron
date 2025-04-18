<?php
	class vault_collectable_model extends cauldron_model {
		public function get_collectables() {
			$query = "select c.*, concat(%s, t.name, %s, m.title) as location from collectables c ".
			         "left join map_token h on c.map_token_id=h.id left join tokens t on h.token_id=t.id ".
			         "left join maps m on h.map_id=m.id where c.adventure_id=%d order by c.name";

			return $this->db->execute($query, "Token ", " in map ", $_SESSION["edit_adventure_id"]);
		}

		public function get_collectable($collectable_id) {
			$query = "select c.* from collectables c, adventures a ".
			         "where c.adventure_id=a.id and c.id=%d and a.dm_id=%d";

			if (($collectables = $this->db->execute($query, $collectable_id, $this->user->id)) == false) {
				return false;
			}

			$collectable = $collectables[0];

			if ($collectable["map_token_id"] != null) {
			$query = "select t.name, m.title from map_token h, tokens t, maps m ".
			         "where h.id=%d and h.token_id=t.id and h.map_id=m.id";

				if (($result = $this->db->execute($query, $collectable["map_token_id"])) != false) {
					$collectable["location"] = "Token ".$result[0]["name"]." in map ".$result[0]["title"];
				}
			}


			return $collectable;
		}


		public function save_okay($collectable, $image) {
			$result = true;

			if (isset($collectable["id"])) {
				if ($this->get_collectable($collectable["id"]) == false) {
					$this->view->add_message("Collectable not found.");
					$result = false;
				}
			}

			if (trim($collectable["name"]) == "") {
				$this->view->add_message("Specify a name.");
				$result = false;
			}

			if (isset($collectable["id"]) == false) {
				if ($image["error"] != 0) {
					$this->view->add_message("Upload an image.");
					$result = false;
				} else if ($this->user->max_resources > 0) {
					$max_capacity = $this->user->max_resources * MB;
					$capacity = $this->borrow("vault/file")->get_directory_size("resources/".$this->user->resources_key);

					if ($capacity + filesize($image["tmp_name"]) > $max_capacity) {
						$this->view->add_message("This file is too big for your maximum resource capacity (%s MB).", $this->user->max_resources);
						return false;
					}
				}
			}

			return $result;
		}

		private function make_filename($id, $name) {
			return $id."_".str_replace(" ", "_", strtolower($name));
		}

		private function save_image($image, $filename) {
			return copy($image["tmp_name"], "resources/".$this->user->resources_key."/collectables/".$filename);
		}

		public function create_collectable($collectable, $image) {
			$keys = array("id", "adventure_id", "name", "description", "image", "found", "hide", "explain");

			$collectable["id"] = null;
			$collectable["adventure_id"] = $_SESSION["edit_adventure_id"];
			$collectable["image"] = "";
			$collectable["found"] = is_true($collectable["found"] ?? false) ? YES : NO;
			$collectable["hide"] = is_true($collectable["hide"] ?? false) ? YES : NO;
			$collectable["explain"] = is_true($collectable["explain"] ?? false) ? YES : NO;

			if ($this->db->insert("collectables", $collectable, $keys) === false) {
				return false;
			}
			$collectable_id = $this->db->last_insert_id;

			$filename = $this->make_filename($collectable_id, $image["name"]);
			if ($this->save_image($image, $filename)) {
				$data = array("image" => $filename);
				$this->db->update("collectables", $collectable_id, $data);
			} else {
				$this->delete_collectable($collectable_id);
				return false;
			}

			return true;
		}

		public function update_collectable($collectable, $image) {
			$keys = array("name", "description", "found", "hide", "explain");

			if ($image["error"] == 0) {
				if (($current = $this->get_collectable($collectable["id"])) == false) {
					return false;
				}

				$filename = "resources/".$this->user->resources_key."/collectables/".$current["image"];
				if (file_exists($filename)) {
					unlink($filename);
				}

				$collectable["image"] = $this->make_filename($collectable["id"], $image["name"]);
				if ($this->save_image($image, $collectable["image"])) {
					array_push($keys, "image");
				} else {
					return false;
				}
			}

			$collectable["found"] = is_true($collectable["found"] ?? false) ? YES : NO;
			$collectable["hide"] = is_true($collectable["hide"] ?? false) ? YES : NO;
			$collectable["explain"] = is_true($collectable["explain"] ?? false) ? YES : NO;

			return $this->db->update("collectables", $collectable["id"], $collectable, $keys);
		}

		public function delete_okay($collectable) {
			$result = true;

			if ($this->get_collectable($collectable["id"]) == false) {
				$this->view->add_message("Collectable not found.");
				$result = false;
			}

			return $result;
		}

		public function delete_collectable($collectable_id) {
			if (($current = $this->get_collectable($collectable_id)) == false) {
				return false;
			}

			if ($this->db->delete("collectables", $collectable_id) == false) {
				return false;
			}

			$filename = "resources/".$this->user->resources_key."/collectables/".$current["image"];
			if (file_exists($filename)) {
				unlink($filename);
			}

			return true;
		}
	}
?>
