<?php
	require "adventure.php";

	class spectate_model extends adventure_model {
		public function get_adventures() {
			$query = "select a.*, u.fullname as dm, o.resources_key, ".
			         "(select count(*) from maps where adventure_id=a.id) as maps ".
			         "from adventures a, users u, organisations o ".
			         "where a.dm_id=u.id and u.organisation_id=o.id";
			if ($this->user->is_admin == false) {
				$query .= " and access>=%d and o.id=%d";
			}
			$query .= " having maps>0 order by last_login desc";

			return $this->db->execute($query, ADVENTURE_ACCESS_PLAYERS_SPECTATORS, $this->user->organisation_id);
		}

		public function get_adventure($adventure_id) {
			$query = "select a.*, u.fullname as dm, o.resources_key ".
			         "from adventures a, users u, organisations o ".
			         "where a.id=%d and a.dm_id=u.id and u.organisation_id=o.id";
			if ($this->user->is_admin == false) {
				$query .= " and access>=%d and o.id=%d";
			}

			if (($adventures = $this->db->execute($query, $adventure_id, ADVENTURE_ACCESS_PLAYERS_SPECTATORS, $this->user->organisation_id)) == false) {
				return false;
			}

			return $adventures[0];
		}
	}
?>
