-- set to 3 months
execute dbms_workload_repository.modify_snapshot_settings (interval => 30, retention => 129600);
