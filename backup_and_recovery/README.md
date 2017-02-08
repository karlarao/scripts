Here's the general workflow: 

- [RmanRecoveryInformation.sql](https://github.com/karlarao/scripts/blob/master/backup_and_recovery/RmanRecoveryInformation.sql) - start with this SQL to assess the recovery situation 
- [RmanBlockCorruption.sql](https://github.com/karlarao/scripts/blob/master/backup_and_recovery/RmanBlockCorruption.sql) - check corruption
- [RmanBackupJobDetails.sql](https://github.com/karlarao/scripts/blob/master/backup_and_recovery/RmanBackupJobDetails.sql) - check the backups
- [RmanMonitor.sql](https://github.com/karlarao/scripts/blob/master/backup_and_recovery/RmanMonitor.sql), [RmanMonitor2.sql](https://github.com/karlarao/scripts/blob/master/backup_and_recovery/RmanMonitor2.sql) - check status of currently running RMAN backup


Read on the following Oracle Center of Excellence papers for action plans based on the recovery situation:


- [https://github.com/karlarao/scripts/tree/master/backup_and_recovery/COE_Backup_And_Recovery_Papers](https://github.com/karlarao/scripts/tree/master/backup_and_recovery/COE_Backup_And_Recovery_Papers) 