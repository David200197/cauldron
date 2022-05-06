<?php
	class cms_map_model extends Banshee\model {
		public function get_games() {
			$query = "select * from games where dm_id=%d order by timestamp desc";

			return $this->db->execute($query, $this->user->id);
		}

		public function is_my_game($game_id) {
			$query = "select * from games where id=%d and dm_id=%d";

			return $this->db->execute($query, $game_id, $this->user->id) != false;
		}

		public function get_maps($game_id) {
			$query = "select * from maps where game_id=%d order by title";

			return $this->db->execute($query, $game_id);
		}

		private function get_files($path) {
			if (($dp = opendir($path)) == false) {
				return false;
			}

			$maps = array();
			while (($file = readdir($dp)) != false) {
				if (substr($file, 0, 1) == ".") {
					continue;
				}

				$file = $path."/".$file;
				if (is_dir($file) == false) {
					array_push($maps, $file);
				} else if (($dir = $this->get_files($file)) != false) {
					$maps = array_merge($maps, $dir);
				}
			}

			closedir($dp);

			return $maps;
		}

		public function get_local_maps() {
			if (($maps = $this->get_files("resources/".$this->user->resources_key."/maps")) !== false) {
				sort($maps);
			}

			$len = strlen($this->user->resources_key);
			foreach ($maps as $m => $map) {
				$maps[$m] = substr($map, 0, 10).substr($map, $len + 11);
			}

			return $maps;
		}

		public function get_map_type($url) {
			$parts = explode(".", $url);
			$extension = array_pop($parts);

			if (in_array($extension, config_array(MAP_IMAGE_EXTENSIONS))) {
				return "image";
			}

			if (in_array($extension, config_array(MAP_VIDEO_EXTENSIONS))) {
				return "video";
			}

			return false;
		}

		public function get_map($map_id) {
			$query = "select m.* from maps m, games g ".
			         "where m.game_id=g.id and m.id=%d and g.dm_id=%d";

			if (($maps = $this->db->execute($query, $map_id, $this->user->id)) == false) {
				return false;
			}
			$map = $maps[0];

			$map["type"] = $this->get_map_type($map["url"]);

			return $map;
		}

		public function get_image_dimensions($map) {
			if (substr($map["url"], 0, 1) == "/") {
				$image = substr($map["url"], 1);
				if (substr($image, 0, 10) == "resources/") {
					$image = "resources/".$this->user->resources_key.substr($image, 9);
				}
			} else {
				list($protocol,, $hostname, $path) = explode("/", $map["url"], 4);
				if ($protocol == "http:") {
					$website = new \Banshee\Protocol\HTTPS($hostname);
				} else if ($protocol == "https:") {
					$website = new \Banshee\Protocol\HTTPS($hostname);
				} else {
					return false;
				}

				if (($result = $website->GET("/".$path)) === false) {
					return false;
				} else if ($result["status"] != 200) {
					return false;
				}

				$image = $result["body"];
			}

			$image = new \Banshee\image($image);

			$map["width"] = $image->width;
			$map["height"] = $image->height;

			return $map;
		}

		public function get_video_dimensions($map) {
			if (substr($map["url"], 0, 1) == "/") {
				$video = substr($map["url"], 1);
				if (substr($video, 0, 10) == "resources/") {
					$video = "resources/".$this->user->resources_key.substr($video, 9);
				}
			} else {
				$this->view->add_system_warning("AUtomatic dimension detection can only be done for local videos.");
				return false;
			}

			require "../libraries/getid3/getid3.php";
			$getID3 = new getID3;
			$info = $getID3->analyze($video);

			$map["width"] = $info["video"]["resolution_x"];
			$map["height"] = $info["video"]["resolution_y"];

			return $map;
		}

		public function save_oke($map) {
			$result = true;

			if (isset($map["id"])) {
				if ($this->get_map($map["id"]) == false) {
					$this->view->add_message("Map not found.");
					$result = false;
				}
			}

			if (trim($map["title"]) == "") {
				$this->view->add_message("Give the map a title.");
				$result = false;
			}

			if (trim($map["url"]) == "") {
				$this->view->add_message("Empty URL is not allowed.");
				$result = false;
			} else {
				list($url) = explode("?", $map["url"], 2);
				$info = pathinfo($url);
				$extensions = array_merge(
					config_array(MAP_IMAGE_EXTENSIONS),
					config_array(MAP_VIDEO_EXTENSIONS));
				if (in_array($info["extension"], $extensions) == false) {
					$this->view->add_message("Unsupported file extension in image/video URL.");
					$result = false;
				}
			}

			$min_size = 2 * $this->settings->screen_grid_size;

			if (((int)$map["width"] < $min_size) || ((int)$map["height"] < $min_size)) {
				$this->view->add_message("The map must be at least %sx%s pixels. Does the map file exists?", $min_size, $min_size);
				$result = false;
			}

			if (valid_input($map["fow_distance"], VALIDATE_NUMBERS, VALIDATE_NONEMPTY) == false) {
				$this->view->add_message("Invalid FoW distance.");
				$result = false;
			} else if ((int)$map["fow_distance"] == 0) {
				$this->view->add_message("Invalid FoW distance.");
				$result = false;
			}

			return $result;
		}

		public function place_characters($game_id, $map_id, $start_x, $start_y) {
			if (($map = $this->db->entry("maps", $map_id)) == false) {
				return false;
			}

			$query = "select l.character_id from game_character l, characters c ".
			         "where l.character_id=c.id and game_id=%d and l.character_id not in ".
			         "(select character_id from map_character where map_id=%d) order by c.name";

			if (($characters = $this->db->execute($query, $game_id, $map_id)) === false) {
				return false;
			}

			$data = array(
				"id"       => null,
				"map_id"   => $map_id,
				"pos_x"    => $start_x,
				"pos_y"    => $start_y,
				"rotation" => 180,
				"hidden"   => NO);

			$positions = array(
				array( 0, -1), array( 1,  1), array(-1,  1), array(-1, -1), // cross
				array( 0, -1), array( 2,  0), array( 0,  2), array(-2,  0), // corners
				array( 0,  1), array( 1,  0), array( 1,  0),
				array(-2,  1), array( 1,  0), array( 1,  0));

			foreach ($characters as $character) {
				$data["character_id"] = $character["character_id"];
				if ($this->db->insert("map_character", $data) == false) {
					return false;
				}

				$delta = array_shift($positions);
				$data["pos_x"] += $delta[0];
				$data["pos_y"] += $delta[1];
				array_push($positions, $delta);
			}

			return true;
		}

		public function create_map($map) {
			$keys = array("id", "game_id", "title", "url", "audio", "width", "height",
			              "grid_size", "show_grid", "drag_character", "fog_of_war",
			              "fow_distance", "start_x", "start_y", "dm_notes");

			$map["id"] = null;
			$map["game_id"] = $_SESSION["edit_game_id"];
			$map["url"] = str_replace(" ", "%20", $map["url"]);
			$map["grid_size"] = 50;
			$map["show_grid"] = NO;
			$map["drag_character"] = is_true($map["drag_character"]) ? YES : NO;
			$map["start_x"] = 2;
			$map["start_y"] = 2;

			if ($this->db->query("begin") === false) {
				return false;
			}

			if ($this->db->insert("maps", $map, $keys) === false) {
				$this->db->query("rollback");
				return false;
			}
			$map_id = $this->db->last_insert_id;

			if ($this->place_characters($_SESSION["edit_game_id"], $map_id, $map["start_x"], $map["start_y"]) === false) {
				$this->db->query("rollback");
				return false;
			}

			if ($this->db->query("commit") === false) {
				return false;
			}

			if (($game = $this->db->entry("games", $_SESSION["edit_game_id"])) != false) {
				if ($game["active_map_id"] == null) {
					$data = array("active_map_id" => $map_id);
					$this->db->update("games", $game["id"], $data);
				}
			}

			return $map_id;
		}

		public function update_map($map) {
			if ($this->get_map($map["id"]) == false) {
				$this->view->add_message("Map not found.");
				return false;
			}

			$keys = array("title", "url", "audio", "width", "height",
			              "drag_character", "fog_of_war", "fow_distance", "dm_notes");

			$map["url"] = str_replace(" ", "%20", $map["url"]);
			$map["drag_character"] = is_true($map["drag_character"]) ? YES : NO;

			return $this->db->update("maps", $map["id"], $map, $keys);
		}

		public function set_grid($map) {
			if ($this->get_map($map["id"]) == false) {
				$this->view->add_message("Map not found.");
				return false;
			}

			$keys = array("grid_size", "show_grid");

			$map["show_grid"] = is_true($map["show_grid"]) ? YES : NO;

			return $this->db->update("maps", $map["id"], $map, $keys);
		}

		public function delete_oke($map) {
			$result = true;

			if ($this->get_map($map["id"]) == false) {
				$this->view->add_message("Map not found.");
				$result = false;
			}

			return $result;
		}

		public function delete_map($map_id) {
			$queries = array(
				array("delete from doors where map_id=%d", $map_id),
				array("delete from walls where map_id=%d", $map_id),
				array("delete from zones where map_id=%d", $map_id),
				array("delete from map_token where map_id=%d", $map_id),
				array("delete from map_character where map_id=%d", $map_id),
				array("update games set active_map_id=null where active_map_id=%d", $map_id),
				array("delete from maps where id=%d", $map_id));

			return $this->db->transaction($queries);
		}
	}
?>
