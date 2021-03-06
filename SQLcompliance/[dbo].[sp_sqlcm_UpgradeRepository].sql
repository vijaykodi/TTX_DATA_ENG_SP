/****** Object:  StoredProcedure [dbo].[sp_sqlcm_UpgradeRepository]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[sp_sqlcm_UpgradeRepository]
as
BEGIN
	SET QUOTED_IDENTIFIER OFF
	--------------------------------------------------------------------------------------------------------------
	-- 1.2 Changes
	--------------------------------------------------------------------------------------------------------------
	-- add column to hold reportingVersion if it doesnt already exist
	if not exists (select c.name,c.id from syscolumns as c,sysobjects as o where c.name='reportingVersion' and o.name='Configuration' and c.id=o.id)
		ALTER TABLE Configuration ADD [reportingVersion] [int] NULL DEFAULT (100);
	
	-- add column to hold repositoryVersion if it doesnt already exist
	if not exists (select c.name,c.id from syscolumns as c,sysobjects as o where c.name='repositoryVersion' and o.name='Configuration' and c.id=o.id)
		ALTER TABLE Configuration ADD [repositoryVersion] [int] NULL DEFAULT (100);
		
	-- Update Change Log Event Type Table
	if not exists (select Name from ChangeLogEventTypes where eventId=50 )
	BEGIN
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (50,'Attach Archive');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (51,'Detach Archive');
	END
		
	--------------------------------------------------------------------------------------------------------------
	-- 2.0  Changes
	--------------------------------------------------------------------------------------------------------------
	--SQLcompliance.Processing
	---------------------------------------------------------------------------------------------------
	IF OBJECT_ID('[SQLcompliance.Processing]..[TraceLogins]') IS NULL
		CREATE TABLE [SQLcompliance.Processing]..[TraceLogins] (
			[instance] [nvarchar] (128) NULL ,
			[loginKey] [int] NULL ,
			[loginValue] [datetime] NULL
		) ON [PRIMARY];
		
	IF NOT EXISTS (SELECT c.name,c.id from [SQLcompliance.Processing]..syscolumns as c,[SQLcompliance.Processing]..sysobjects as o where c.name='FileName' and o.name='TraceStates' and c.id=o.id)		
		ALTER TABLE [SQLcompliance.Processing]..[TraceStates] ADD
			[FileName]         [nvarchar] (128) NULL ,
			[LinkedServerName] [nvarchar] (128) NULL ,
			[ParentName]       [nvarchar] (128) NULL ,
			[IsSystem]         [int] NULL ,
			[SessionLoginName] [nvarchar] (128) NULL ,
			[ProviderName]     [nvarchar] (128) NULL;

	--SQLcompliance
	---------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='auditBroker' and o.name='Databases' and c.id=o.id)		
		ALTER TABLE [SQLcompliance]..[Databases] ADD
			[auditBroker] [tinyint] NULL DEFAULT (0),
			[auditLogins] [tinyint] NULL DEFAULT (1);

	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='is2005Only' and o.name='EventTypes' and c.id=o.id)
	BEGIN
		ALTER TABLE [SQLcompliance]..[EventTypes] ADD
			[is2005Only] [tinyint] NULL DEFAULT (0),
			[isExcludable] [tinyint] NULL DEFAULT (0);

		EXEC('UPDATE [SQLcompliance]..[EventTypes] SET is2005Only=0');
	END

	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='alertHighWatermark' and o.name='Servers' and c.id=o.id)
	BEGIN
		ALTER TABLE [SQLcompliance]..[Servers] ADD
		  [alertHighWatermark] [int]  DEFAULT (-2100000000) NULL,
			[auditDBCC] [tinyint] NULL DEFAULT(0),
			[auditSystemEvents] [tinyint] NULL DEFAULT (0);
		
		EXEC('UPDATE [SQLcompliance]..[Servers] SET [alertHighWatermark]=[highWatermark]');
	END

	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='auditDBCC' and o.name='Configuration' and c.id=o.id)
		ALTER TABLE [SQLcompliance]..[Configuration] ADD
			[auditDBCC] [tinyint] NULL DEFAULT(0),
			[auditSystemEvents] [tinyint] NULL DEFAULT (0),
			[smtpServer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[smtpPort] [int] NULL ,
			[smtpAuthType] [int] NULL ,
			[smtpSsl] [tinyint] NULL ,
			[smtpUsername] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[smtpPassword] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[smtpSenderAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[smtpSenderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		  [loginCollapse] [tinyint] NULL DEFAULT(0) ,
		  [loginTimespan] [int] NULL DEFAULT (60) ,
		  [loginCacheSize] [int] NULL DEFAULT (1000);

	-- Alerting Support
	IF OBJECT_ID('ActionResultStatusTypes') IS NULL
	BEGIN
		CREATE TABLE [SQLcompliance]..[ActionResultStatusTypes] (
			[statusTypeId] [int] NOT NULL ,
			[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			CONSTRAINT [PK_ActionResultStatusTypes] PRIMARY KEY  CLUSTERED 
			(
				[statusTypeId]
			)  ON [PRIMARY] 
		) ON [PRIMARY];		
		GRANT SELECT ON [ActionResultStatusTypes] TO [public];
		INSERT INTO ActionResultStatusTypes (statusTypeId, name) VALUES (0, 'Success'); 
		INSERT INTO ActionResultStatusTypes (statusTypeId, name) VALUES (1, 'Failure') ;
		INSERT INTO ActionResultStatusTypes (statusTypeId, name) VALUES (2, 'Pending') ;
		INSERT INTO ActionResultStatusTypes (statusTypeId, name) VALUES (3, 'Uninitialized');
	END

	IF OBJECT_ID('AlertTypes') IS NULL
	BEGIN
		CREATE TABLE [SQLcompliance]..[AlertTypes] (
			[alertTypeId] [int] NOT NULL ,
			[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			CONSTRAINT [PK_AlertTypes] PRIMARY KEY  CLUSTERED 
			(
				[alertTypeId]
			)  ON [PRIMARY] 
		) ON [PRIMARY];
		GRANT SELECT ON [AlertTypes] TO [public];
		INSERT INTO AlertTypes (alertTypeId, name) VALUES (1, 'Audited SQL Server');
	END
	
	IF OBJECT_ID('Alerts') IS NULL
	BEGIN
		CREATE TABLE [SQLcompliance]..[Alerts] (
			[alertId] [int] IDENTITY (-2100000000, 1) NOT NULL ,
			[alertType] [int] NOT NULL ,
			[alertRuleId] [int] NOT NULL ,
			[alertEventId] [int] NOT NULL ,
			[instance] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[eventType] [int] NOT NULL ,
			[created] [datetime] NOT NULL CONSTRAINT [DF_Alerts_created] DEFAULT (getutcdate()),
			[alertLevel] [tinyint] NOT NULL ,
			[emailStatus] [tinyint] NOT NULL,
			[logStatus] [tinyint] NOT NULL,
			[message]  [nvarchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[ruleName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			CONSTRAINT [PK_Alerts] PRIMARY KEY  CLUSTERED 
			(
				[alertId]
			)  ON [PRIMARY] ,
			CONSTRAINT [FK_Alerts_AlertTypes] FOREIGN KEY 
			(
				[alertType]
			) REFERENCES [SQLcompliance]..[AlertTypes] (
				[alertTypeId]
			)
		) ON [PRIMARY];
		GRANT SELECT ON [Alerts] TO [public];
		
		CREATE  INDEX [IX_Alerts_created] ON [dbo].[Alerts]([created] DESC, [alertId] DESC ) ON [PRIMARY];
		CREATE  INDEX [IX_Alerts_alertLevel] ON [dbo].[Alerts]([alertLevel], [alertId] DESC ) ON [PRIMARY];
		CREATE  INDEX [IX_Alerts_eventType] ON [dbo].[Alerts]([eventType], [alertId] DESC ) ON [PRIMARY];
	END
		
	IF OBJECT_ID('AlertRules') IS NULL
	BEGIN
		CREATE TABLE [SQLcompliance]..[AlertRules] (
			[ruleId] [int] IDENTITY (-2100000000, 1) NOT NULL ,
			[name] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[description] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[alertLevel] [tinyint] NOT NULL ,
			[alertType] [int] NOT NULL ,
			[targetInstances] [nvarchar] (640) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[enabled] [tinyint] NOT NULL ,
			[message] [nvarchar] (2500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[logMessage] [tinyint] NOT NULL,
			[emailMessage] [tinyint] NOT NULL,
			CONSTRAINT [PK_AlertRules] PRIMARY KEY  CLUSTERED 
			(
				[ruleId]
			)  ON [PRIMARY] ,
			CONSTRAINT [FK_AlertRules_AlertTypes] FOREIGN KEY 
			(
				[alertType]
			) REFERENCES [SQLcompliance]..[AlertTypes] (
				[alertTypeId]
			)
		) ON [PRIMARY];
		GRANT SELECT ON [AlertRules] TO [public];
	END

	IF OBJECT_ID('AlertRuleConditions') IS NULL
	BEGIN
		CREATE TABLE [SQLcompliance]..[AlertRuleConditions] (
			[conditionId] [int] IDENTITY (-2100000000, 1) NOT NULL ,
			[ruleId] [int] NOT NULL ,
			[fieldId] [int] NOT NULL ,
			[matchString] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			CONSTRAINT [PK_AlertRuleConditions] PRIMARY KEY  CLUSTERED 
			(
				[conditionId]
			)  ON [PRIMARY] ,
			CONSTRAINT [FK_AlertRuleConditions_AlertRules] FOREIGN KEY 
			(
				[ruleId]
			) REFERENCES [SQLcompliance]..[AlertRules] (
				[ruleId]
			)
		) ON [PRIMARY];
		GRANT SELECT ON [AlertRuleConditions] TO [public];
	END
	
	IF NOT EXISTS(select Name from ChangeLogEventTypes where eventId=52 )
	BEGIN
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (52,'Login Filtering Changed');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (53,'Alert Rule Added');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (54,'Alert Rule Removed');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (55,'Alert Rule Modified');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (56,'Alert Rule Disabled');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (57,'Alert Rule Enabled');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (58,'Groom Alerts');
	END

	IF NOT EXISTS(select Name from AgentEventTypes where eventId=17 )
	BEGIN
		INSERT INTO [AgentEventTypes] ([eventId],[Name])	VALUES (17,'Incompatible SQL Server version error');
	END


	IF NOT EXISTS(select name from ObjectTypes where objtypeId=8259 )
	BEGIN
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8259,'CHECK');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8260,'DEFAULT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8262,'FOREIGN KEY');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8272,'STORED PROCEDURE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8274,'RULE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8275,'SYSTEM TABLE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8276,'SERVER TRIGGER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8277,'USER TABLE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8278,'VIEW');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (8280,'EXTENDED SP');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (16724,'CLR TRIGGER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (16964,'DATABASE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (16975,'OBJECT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17222,'FULL TEXT CATALOG');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17232,'CLR STORED PROCEDURE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17235,'SCHEMA');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17475,'CREDENTIAL');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17491,'DDL EVENT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17741,'MGMT EVENT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17747,'SECURITY EVENT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17749,'USER EVENT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17985,'CLR AGGREGATE FUNCTION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (17993,'INLINE FUNCTION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (18000,'PARTITION FUNCTION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (18002,'REPL FILTER PROC');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (18004,'TABLE VALUED UDF');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (18259,'SERVER ROLE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (18263,'MICROSOFT WINDOWS GROUP');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19265,'ASYMMETRIC KEY');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19277,'MASTER KEY');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19280,'PRIMARY KEY');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19283,'OBFUS KEY');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19521,'ASYMMETRIC KEY LOGIN');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19523,'CERTIFICATE LOGIN');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19538,'ROLE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19539,'SQL LOGIN');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (19543,'WINDOWS LOGIN');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20034,'REMOTE SERVICE BINDING');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20036,'EVENT NOTIFICATION DATABASE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20037,'EVENT NOTIFICATION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20038,'SCALAR FUNCTION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20047,'EVENT NOTIFICATION OBJECT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20051,'SYNONYM');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20549,'ENDPOINT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20801,'CACHED ADHOC QUERIES');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20816,'CACHED ADHOC QUERIES');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20819,'SERVICE BROKER QUEUE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (20821,'UNIQUE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21057,'APPLICATION ROLE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21059,'CERTIFICATE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21075,'SERVER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21076,'TSQL TRIGGER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21313,'ASSEMBLY');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21318,'CLR SCALAR FUNCTION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21321,'INLINE SCALAR FUNCTION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21328,'PARTITION SCHEME');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21333,'USER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21571,'SERVICE BROKER CONTRACT');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21572,'DATABASE TRIGGER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21574,'CLR TABLE FUNCTION');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21577,'INTERNAL TABLE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21581,'SERVICE BROKER MSG TYPE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21586,'SERVICE BROKER ROUTE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21587,'STATISTICS');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21825,'USER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21827,'USER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21831,'USER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21843,'USER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (21847,'USER');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (22099,'SERVICE BROKER SERVICE');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (22601,'INDEX');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (22604,'CERTIFICATE LOGIN');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (22611,'XML SCHEMA');
		INSERT INTO [ObjectTypes] ([objtypeId],[name]) 	VALUES (22868,'TYPE');
	END
	
	--------------------------------------------------------------------------------------------------------------
	-- 2.1 Changes
	--------------------------------------------------------------------------------------------------------------
	-- SQLcompliance database modifications
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='auditUDE' and o.name='Servers' and c.id=o.id)
		ALTER TABLE [SQLcompliance]..[Servers] ADD
			[auditUDE] [tinyint] NULL DEFAULT (0),
			[auditUserUDE] [tinyint] NULL DEFAULT (0),
			[agentDetectionInterval] [int] NULL DEFAULT (60);

	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='archiveCheckIntegrity' and o.name='Configuration' and c.id=o.id)
		ALTER TABLE [SQLcompliance]..[Configuration] ADD
			[archiveCheckIntegrity] [tinyint] NOT NULL DEFAULT (1);

	-- Event Filter Support
	IF OBJECT_ID('EventFilters') IS NULL
	BEGIN
		CREATE TABLE [SQLcompliance]..[EventFilters] (
			[filterId] [int] IDENTITY (-2100000000, 1) NOT NULL ,
			[name] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[description] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[eventType] [int] NOT NULL ,
			[targetInstances] [nvarchar] (640) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[enabled] [tinyint] NOT NULL ,
			CONSTRAINT [PK_EventFilters] PRIMARY KEY  CLUSTERED 
			(
				[filterId]
			)  ON [PRIMARY] ,
		) ON [PRIMARY];
		GRANT SELECT ON [EventFilters] TO [public]
	END

	IF OBJECT_ID('EventFilterConditions') IS NULL
	BEGIN
		CREATE TABLE [SQLcompliance]..[EventFilterConditions] (
			[conditionId] [int] IDENTITY (-2100000000, 1) NOT NULL ,
			[filterId] [int] NOT NULL ,
			[fieldId] [int] NOT NULL ,
			[matchString] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			CONSTRAINT [PK_EventFilterConditions] PRIMARY KEY  CLUSTERED 
			(
				[conditionId]
			)  ON [PRIMARY] ,
			CONSTRAINT [FK_EventFilterConditions_EventFilters] FOREIGN KEY 
			(
				[filterId]
			) REFERENCES [dbo].[EventFilters] (
				[filterId]
			)
		) ON [PRIMARY];
		GRANT SELECT ON [EventFilterConditions] TO [public]
	END
	
	IF NOT EXISTS(select Name from ChangeLogEventTypes where eventId=59 )
	BEGIN
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (59,'Event Filter Added');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (60,'Event Filter Removed');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (61,'Event Filter Modified');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (62,'Event Filter Disabled');
		INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (63,'Event Filter Enabled');
	END

	IF NOT EXISTS(select Name from AgentEventTypes where eventId=18 )
	BEGIN
		INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (18,'Audit trace stopped warning');
		INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (19,'Audit trace closed warning');
		INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (20,'Audit trace altered warning');
	END
	
	IF NOT EXISTS(select name from EventTypes where evtypeid=1800)
	BEGIN
		EXEC sp_sqlcm_UpdateEventTypes;
	END
	
	IF EXISTS(select name from EventTypes where evtypeid=1500)
	BEGIN
		EXEC sp_sqlcm_UpdateEventTypes;
	END
	
	--------------------------------------------------------------------------------------------------------------
	-- 3.0 Changes
	--------------------------------------------------------------------------------------------------------------
	-- Add trusted user column to the Databases table
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='auditUsersList' and o.name='Databases' and c.id=o.id)
		ALTER TABLE [Databases] ADD [auditUsersList] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL;

	-- Stats categories
	---------------------------
	IF OBJECT_ID('StatsCategories') IS NULL
	BEGIN
		CREATE TABLE [StatsCategories] ( [category] [int] NOT NULL, [name] [nvarchar] (64) NOT NULL );
		GRANT SELECT ON [StatsCategories] TO [public];
		INSERT INTO StatsCategories (category, name) VALUES (0, 'Unknown');
		INSERT INTO StatsCategories (category, name) VALUES (1, 'Audited Instances');
		INSERT INTO StatsCategories (category, name) VALUES (2, 'Audited Databases');
		INSERT INTO StatsCategories (category, name) VALUES (3, 'Processed Events');
		INSERT INTO StatsCategories (category, name) VALUES (4, 'Alerts');
		INSERT INTO StatsCategories (category, name) VALUES (5, 'Privileged User Events');
		INSERT INTO StatsCategories (category, name) VALUES (6, 'Failed Logins');
		INSERT INTO StatsCategories (category, name) VALUES (7, 'User Defined Events');
		INSERT INTO StatsCategories (category, name) VALUES (8, 'Admin');
		INSERT INTO StatsCategories (category, name) VALUES (9, 'DDL');
		INSERT INTO StatsCategories (category, name) VALUES (10, 'Security');
		INSERT INTO StatsCategories (category, name) VALUES (11, 'DML');
		INSERT INTO StatsCategories (category, name) VALUES (12, 'Insert');
		INSERT INTO StatsCategories (category, name) VALUES (13, 'Update');
		INSERT INTO StatsCategories (category, name) VALUES (14, 'Delete');
		INSERT INTO StatsCategories (category, name) VALUES (15, 'Select');
		INSERT INTO StatsCategories (category, name) VALUES (16, 'Logins');
		INSERT INTO StatsCategories (category, name) VALUES (17, 'Agent Trace Directory Size');
		INSERT INTO StatsCategories (category, name) VALUES (18, 'Integrity Check');
		INSERT INTO StatsCategories (category, name) VALUES (19, 'Execute');
		INSERT INTO StatsCategories (category, name) VALUES (20, 'Event Received');
		INSERT INTO StatsCategories (category, name) VALUES (21, 'Event Processed');
		INSERT INTO StatsCategories (category, name) VALUES (22, 'Event Filtered');		
	END
	
	IF OBJECT_ID('ReportCard') IS NULL
	BEGIN
		CREATE TABLE [dbo].[ReportCard](
			[srvId] [int] NOT NULL,
			[statId] [int] NOT NULL,
			[warningThreshold] [int] NOT NULL,
			[errorThreshold] [int] NOT NULL,
			[period] [int] NOT NULL,
			[enabled] [tinyint] NOT NULL
		) ON [PRIMARY];
		GRANT SELECT ON [ReportCard] TO [public];
	END

	-- Create the licenses table
	IF OBJECT_ID('Licenses') IS NULL
	BEGIN
		CREATE TABLE [dbo].[Licenses] (
	    [licenseid] INTEGER IDENTITY(1,1) NOT NULL,
	    [licensekey] NVARCHAR(256) NOT NULL,
	    [createdby] NVARCHAR(500) NOT NULL,
	    [createdtm] DATETIME NOT NULL,
	    CONSTRAINT [PK__applicationlicen__46E78A0C] PRIMARY KEY ([licenseid])
		);
	END
	-- This was missed in the 3.0 upgrade path - just do it by default
	GRANT SELECT ON [Licenses] TO [public]

	--------------------------------------------------------------------------------------------------------------
	-- 3.1 Changes	
	--------------------------------------------------------------------------------------------------------------
	-- the table that holds the tables being monitored for data changes across all instances
	IF OBJECT_ID('DataChangeTables') IS NULL
	BEGIN
		CREATE TABLE DataChangeTables ( srvId int not null,
										dbId int not null,
										objectId int not null,
                                        schemaName nVarchar(128) not null,
										tableName nVarchar(128) not null,
										rowLimit int not null default (20),
										CONSTRAINT [PK_DataChangeTables] PRIMARY KEY CLUSTERED (srvId, dbId, objectId )  )
			on [PRIMARY];
		GRANT SELECT ON [DataChangeTables] TO [public];
	END

	-- Add a new column to the databases table for indicating whether there are tables monitored for data changes 
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='auditDataChanges' and o.name='Databases' and c.id=o.id)
		ALTER TABLE Databases ADD auditDataChanges tinyint not null default 0;

	-- Add a new column to the DatabaseObjects table for schema support
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='schemaName' and o.name='DatabaseObjects' and c.id=o.id)
	BEGIN
		ALTER TABLE DatabaseObjects ADD schemaName nvarchar(128) not null default 'dbo';
	END

	-- Update Reports Table
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='port' and o.name='Reports' and c.id=o.id)
	BEGIN
	   DROP TABLE [Reports];
      CREATE TABLE [Reports] (
      	[reportServer] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
      	[serverVirtualDirectory] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
      	[managerVirtualDirectory] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
      	[port] [int] NULL ,
      	[useSsl] [tinyint] NULL ,
      	[userName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
      	[repository] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
      	[targetDirectory] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
      ) ON [PRIMARY];
		GRANT SELECT ON [Reports] TO [public];
	END
	
	IF NOT EXISTS (SELECT c.name,c.id from [SQLcompliance.Processing]..syscolumns as c,[SQLcompliance.Processing]..sysobjects as o where c.name='eventSequence' and o.name='TraceStates' and c.id=o.id)		
	ALTER TABLE [SQLcompliance.Processing]..[TraceStates] ADD
		[eventSequence]         [bigint] NULL ;
		
	IF NOT EXISTS (SELECT c.name,c.id from [SQLcompliance]..syscolumns as c,[SQLcompliance]..sysobjects as o where c.name='details' and o.name='AgentEvents' and c.id=o.id)		
	ALTER TABLE [SQLcompliance]..[AgentEvents] ADD
   	[details] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL;
		
	IF NOT EXISTS (SELECT c.name,c.id from [SQLcompliance]..syscolumns as c,[SQLcompliance]..sysobjects as o where c.name='agentHealth' and o.name='Servers' and c.id=o.id)		
	ALTER TABLE [SQLcompliance]..[Servers] ADD
      [agentHealth] [bigint] DEFAULT(0) NULL;
      
	IF NOT EXISTS(select name from EventTypes where evtypeid=900001)
	BEGIN
   	INSERT INTO [EventTypes] ([evtypeid],[evcatid],[name],[category],[is2005Only],[isExcludable])	VALUES (900001,4,'Encrypted','DML',0,0);
	END
	
	IF NOT EXISTS(select Name from AgentEventTypes where eventId=1001 )
	BEGIN
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (1001,'Agent Warning');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (3001,'Agent Warning Resolution');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (2001,'Agent Configuration Error');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (4001,'Agent Configuration Resolution');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (2002,'Trace Directory Error');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (4002,'Trace Directory Resolution');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (2003,'SQL Trace Error');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (4003,'SQL Trace Resolution');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (2004,'Server Connection Error');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (4004,'Server Connection Resolution');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (2005,'Collection Service Connection Error');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (4005,'Collection Service Connection Resolution');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (2006,'CLR Error');
      INSERT INTO [AgentEventTypes] ([eventId],[Name]) VALUES (4006,'CLR Resolution');
	END      
	
	UPDATE [SQLcompliance]..[EventTypes] SET [isExcludable]=1 WHERE evtypeid=139;
	UPDATE [SQLcompliance]..[EventTypes] SET [isExcludable]=1 WHERE evtypeid=339;
		
	UPDATE Configuration SET reportingVersion=103
	UPDATE Configuration SET repositoryVersion=100

	--------------------------------------------------------------------------------------------------------------
	-- 3.2 Changes
	--------------------------------------------------------------------------------------------------------------
	-- Main compliance database
	-- Add a new column to the DataChangeTables table for selected column auditing support
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='selectedColumns' and o.name='DataChangeTables' and c.id=o.id)
	BEGIN
		ALTER TABLE DataChangeTables ADD selectedColumns tinyint not null default 0;
	END

	-- Add a new table for selected column auditing support
	IF OBJECT_ID('DataChangeColumns') IS NULL
	BEGIN
		CREATE TABLE [dbo].[DataChangeColumns](
			[srvId] [int] NOT NULL,
			[dbId] [int] NOT NULL,
			[objectId] [int] NOT NULL,
			[name] [nvarchar](128) NOT NULL,
			CONSTRAINT [FK_DataChangeColumns_DataChangeTables] FOREIGN KEY 
			(
				[srvId],
				[dbId],
				[objectId]
			) REFERENCES [dbo].[DataChangeTables] (
				[srvId],
				[dbId],
				[objectId]
			)
		) ON [PRIMARY];

		GRANT SELECT ON [DataChangeColumns] TO [public];
	END
		
	-- Add a new alert type for supporting operational status alerts
	IF NOT EXISTS(select alertTypeId from AlertTypes where alertTypeId=2 )
	BEGIN
		INSERT INTO [AlertTypes] ([alertTypeId], [name]) VALUES (2, 'SQLcompliance Status');
	END
	
	-- add column to hold collection server heartbeat interval if it doesnt already exist
	if NOT EXISTS (SELECT c.name,c.id FROM syscolumns AS c,sysobjects AS o WHERE c.name='collectionServerHeartbeatInterval' and o.name='Configuration' and c.id=o.id)
	BEGIN
		ALTER TABLE Configuration ADD [collectionServerHeartbeatInterval] [int] NOT NULL DEFAULT (5);	
	END
	
	if NOT EXISTS (SELECT c.name,c.id FROM syscolumns AS c,sysobjects AS o WHERE c.name='computerName' and o.name='Alerts' and c.id=o.id)
	BEGIN
		ALTER TABLE Alerts ADD [computerName] [nvarchar](256) NULL;	
	END
	
	if NOT EXISTS (SELECT c.name,c.id FROM syscolumns AS c,sysobjects AS o WHERE c.name='indexStartTime' and o.name='Configuration' and c.id=o.id)
	BEGIN
		ALTER TABLE Configuration ADD [indexStartTime] [datetime] NULL,
									  [indexDurationInSeconds] [int] NULL;	
		
	END

	IF OBJECT_ID('StatusRuleTypes') IS NULL
	BEGIN
	   CREATE TABLE [dbo].[StatusRuleTypes](
	      [StatusRuleId] [int] NOT NULL,
	      [RuleName] [nvarchar](100) NOT NULL
	      CONSTRAINT [PK_StatusRuleId] PRIMARY KEY  CLUSTERED 
	      (
			   [StatusRuleId]
		   )  
		)ON [PRIMARY]
	   GRANT SELECT ON [StatusRuleTypes] TO [public]
	END

	IF NOT EXISTS(select RuleName from StatusRuleTypes where StatusRuleId=1)
	BEGIN
      INSERT INTO StatusRuleTypes (StatusRuleId, RuleName) VALUES (1, 'Agent trace directory reached size limit')
      INSERT INTO StatusRuleTypes (StatusRuleId, RuleName) VALUES (2, 'Collection Server trace directory reached size limit');
      INSERT INTO StatusRuleTypes (StatusRuleId, RuleName) VALUES (3, 'Agent heartbeat was not received');
      INSERT INTO StatusRuleTypes (StatusRuleId, RuleName) VALUES (4, 'Event database is too large');
      INSERT INTO StatusRuleTypes (StatusRuleId, RuleName) VALUES (5, 'Agent cannot connect to audited instance');
	END
	
	IF NOT EXISTS (SELECT Name FROM ChangeLogEventTypes WHERE eventId=64)
	BEGIN
      INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (64, 'Re-Index Started')
      INSERT INTO [ChangeLogEventTypes] ([eventId],[Name]) VALUES (65, 'Re-Index Finished')
	END
			
	--------------------------------------------------------------------------------------------------------------
	-- 3.3 Changes
	--------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT c.name,c.id FROM syscolumns AS c,sysobjects AS o WHERE c.name='agentTraceStartTimeout' and o.name='Servers' and c.id=o.id)
	BEGIN
		ALTER TABLE Servers ADD [agentTraceStartTimeout] [int] NULL;	
	END
		
	--------------------------------------------------------------------------------------------------------------
	-- 3.5 Changes
	--------------------------------------------------------------------------------------------------------------
	IF OBJECT_ID('SensitiveColumnTables') IS NULL
	BEGIN
		CREATE TABLE SensitiveColumnTables ( 
			[srvId] [int] NOT NULL,
			[dbId] [int] NOT NULL,
			[objectId] [int] NOT NULL,
			[schemaName] [nvarchar] (128) NOT NULL,
			[tableName] [nvarchar] (128) NOT NULL,
			[selectedColumns] [tinyint] NOT NULL DEFAULT 1,
			CONSTRAINT [PK_SensitiveColumnTables] PRIMARY KEY CLUSTERED 
			(
				[srvId], 
				[dbId], 
				[objectId]
			)
		) ON [PRIMARY]

		CREATE TABLE [dbo].[SensitiveColumnColumns](
			[srvId] [int] NOT NULL,
			[dbId] [int] NOT NULL,
			[objectId] [int] NOT NULL,
			[name] [nvarchar](128) NOT NULL,
			CONSTRAINT [FK_SensitiveColumnColumns_SensitiveColumnTables] FOREIGN KEY 
			(
				[srvId],
				[dbId],
				[objectId]
			) REFERENCES [dbo].[SensitiveColumnTables] (
				[srvId],
				[dbId],
				[objectId]
			)
		) ON [PRIMARY]
		
		GRANT SELECT ON [SensitiveColumnTables] TO [public];
		GRANT SELECT ON [SensitiveColumnColumns] TO [public];
	END
	
	IF NOT EXISTS (SELECT c.name,c.id from syscolumns as c,sysobjects as o where c.name='auditSensitiveColumns' and o.name='Databases' and c.id=o.id)
	BEGIN
		ALTER TABLE Databases ADD auditSensitiveColumns tinyint NOT NULL DEFAULT 0,
								  auditCaptureTrans tinyint NULL DEFAULT 0;
	END	
	
	IF NOT EXISTS (SELECT c.name,c.id FROM syscolumns AS c,sysobjects AS o WHERE c.name='auditUserCaptureTrans' and o.name='Servers' and c.id=o.id)
	BEGIN
		ALTER TABLE Servers ADD [auditUserCaptureTrans] [tinyint] NULL DEFAULT (0);	
	END
	
	
	IF NOT EXISTS(select name from EventTypes where evtypeid=40)
	BEGIN
		INSERT INTO [EventTypes] ([evtypeid],[evcatid],[name],[category],[is2005Only],[isExcludable])	VALUES (40,4,'Begin Transaction','DML',0,1)
		INSERT INTO [EventTypes] ([evtypeid],[evcatid],[name],[category],[is2005Only],[isExcludable])	VALUES (41,4,'Commit Transaction','DML',0,1)
		INSERT INTO [EventTypes] ([evtypeid],[evcatid],[name],[category],[is2005Only],[isExcludable])	VALUES (42,4,'Rollback Transaction','DML',0,1)
		INSERT INTO [EventTypes] ([evtypeid],[evcatid],[name],[category],[is2005Only],[isExcludable])	VALUES (43,4,'Save Transaction','DML',0,1)
	END
		
	--------------------------------------------------------------------------------------------------------------
	-- 3.6 Changes
	--------------------------------------------------------------------------------------------------------------	
	IF OBJECT_ID('DataRuleTypes') IS NULL
	BEGIN
		CREATE TABLE [dbo].[DataRuleTypes] (
		   [DataRuleId] [int] NOT NULL,
		   [RuleName] [nvarchar](100) NOT NULL
		   CONSTRAINT [PK_DataRuleId] PRIMARY KEY  CLUSTERED 
		   (
			   [DataRuleId]
		   )  
		) ON [PRIMARY]
		GRANT SELECT ON [DataRuleTypes] TO [public]
	END
	
	IF NOT EXISTS(select RuleName from DataRuleTypes where DataRuleId=1)
	BEGIN
      INSERT INTO DataRuleTypes (DataRuleId, RuleName) VALUES (1, 'Sensitive Column Accessed')
      INSERT INTO DataRuleTypes (DataRuleId, RuleName) VALUES (2, 'Numeric Column Value Changed');
    END		
    
	-- Add a new alert type for supporting operational status alerts
	IF NOT EXISTS(select alertTypeId from AlertTypes where alertTypeId=3 )
	BEGIN
		INSERT INTO [AlertTypes] ([alertTypeId], [name]) VALUES (3, 'Data Alert');
	END
	
	IF NOT EXISTS (SELECT c.name,c.id FROM syscolumns AS c,sysobjects AS o WHERE c.name='refactorTable' and o.name='Configuration' and c.id=o.id)
	BEGIN
		DECLARE @config INT
		SET @config = (SELECT [sqlComplianceDbSchemaVersion] FROM Configuration)

		--this should work ok since there is only one row in the configuration table, 
		IF (@config = 802 or @config = 803)
			ALTER TABLE Configuration ADD [refactorTable] [tinyint] NOT NULL DEFAULT (1);	
		else
			ALTER TABLE Configuration ADD [refactorTable] [tinyint] NULL DEFAULT (0);	
	END
		
    
	--******  update the repository schema version after applying all of the changes  ******
	IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_Alerts_created')
		UPDATE [SQLcompliance]..[Configuration] SET [sqlComplianceDbSchemaVersion]=902,[eventsDbSchemaVersion ]=703;
	ELSE
		UPDATE [SQLcompliance]..[Configuration] SET [sqlComplianceDbSchemaVersion]=901,[eventsDbSchemaVersion ]=703;
END

GO
