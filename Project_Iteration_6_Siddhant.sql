--TABLES
--Replace this with your table creations.

--Employee Table
CREATE TABLE Employee (
	EmployeeID DECIMAL(5) PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	UserName VARCHAR(50) NOT NULL UNIQUE, --Needs a trigger. Composed of the first letter of the first name and the last name. Should automatically append a number if the same username exist.
	EmployeeLocation VARCHAR(50) NOT NULL
);

--Resource Table
CREATE TABLE Resources (
	EmployeeID DECIMAL(5) PRIMARY KEY, --Can create trigger to automatically add an employee to the resource table if selected as a resource in a project. 
	CONSTRAINT resources_employee_id_fk 
	FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

--Project Manager Table
CREATE TABLE ProjectManager (
	EmployeeID DECIMAL(5) PRIMARY KEY, --Can create trigger to automatically add an employee to the project manager table if selected as a PM in a project. 
	CONSTRAINT pm_employee_id_fk 
	FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

--Customer Table
CREATE TABLE Customer (
	CustomerID DECIMAL(5) PRIMARY KEY,
	CustomerName VARCHAR(255) NOT NULL UNIQUE,
	ContactFirstName VARCHAR(255) NOT NULL,
	ContactLastName VARCHAR(255) NOT NULL,
	DesignatedEmail VARCHAR(255) NOT NULL UNIQUE,
	DesignatedPhone DECIMAL(10)
);

--Project Table
CREATE TABLE Project (
	ProjectID DECIMAL(5) PRIMARY KEY,
	PMEmployeeID DECIMAL(5) NOT NULL,
	CustomerID DECIMAL(5) NOT NULL,
	ProjectName VARCHAR(255) NOT NULL UNIQUE,
	ProjectDescription VARCHAR(255) NOT NULL,
	isTimeAndMaterial BIT NOT NULL,
	EstimatedProjectHours DECIMAL(10) NOT NULL,
	ProjectCost DECIMAL(10),
	StartDate DATE NOT NULL,
	EstimatedEndDate DATE NOT NULL,
	ActualEndDate DATE,

	CONSTRAINT project_pm_fk
	FOREIGN KEY (PMEmployeeID) REFERENCES Employee(EmployeeID), 

	CONSTRAINT customer_project_fk
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

--Fixed Bid Table
CREATE TABLE FixedBidProject (
	ProjectID DECIMAL(5) PRIMARY KEY,
	CONSTRAINT fixedbidproject_fk
	FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

--Time and Material Table
CREATE TABLE TimeMaterialProject (
	ProjectID DECIMAL(5) PRIMARY KEY,
	CONSTRAINT timeandmaterial_fk
	FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

--Project Resource Association Table
CREATE TABLE ProjectResourceAssociation (
	AssociationID DECIMAL(5) PRIMARY KEY,
	ProjectID DECIMAL(5) NOT NULL,
	ResourceEmployeeID DECIMAL(5),

	CONSTRAINT project_resource_allocation_project_id_fk
	FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID),

	CONSTRAINT project_resource_allocation_employee_id_fk
	FOREIGN KEY (ResourceEmployeeID) REFERENCES Employee(EmployeeID) 
);

--Task Table
CREATE TABLE Task (
	TaskID DECIMAL(5) PRIMARY KEY,
	TaskName VARCHAR(255) NOT NULL,
	IsBillable BIT NOT NULL --Create a trigger to insert, update or delete the billable or non billable task table based on IsBillable
);

--BillableTask
CREATE TABLE BillableTask (
	TaskID DECIMAL(5) PRIMARY KEY,
	CONSTRAINT billabletask_fk
	FOREIGN KEY (TaskID) REFERENCES Task(TaskID)
);

--Non-Billable Task
CREATE TABLE NonBillableTask (
	TaskID DECIMAL(5) PRIMARY KEY,
	CONSTRAINT nonbillabletask_fk
	FOREIGN KEY (TaskID) REFERENCES Task(TaskID)
);

--Timesheet Table
CREATE TABLE Timesheet (
	TimesheetID DECIMAL(5) PRIMARY KEY,
	ResourceEmployeeID DECIMAL(5) NOT NULL,
	PMEmployeeID DECIMAL(5) NOT NULL,
	TimesheetDate DATE NOT NULL,
	SubmittedDate DATE NOT NULL,
	IsApproved BIT,
	ApprovedDate DATE,

	CONSTRAINT timesheet_resource_fk
	FOREIGN KEY (ResourceEmployeeID) REFERENCES Employee (EmployeeID),

	CONSTRAINT timesheet_pm_fk
	FOREIGN KEY (PMEmployeeID) REFERENCES Employee (EmployeeID)
);

--ProjectTimesheet Association Table
CREATE TABLE ProjectTimesheet (
	ProjectTimesheetID DECIMAL(5) PRIMARY KEY,
	ProjectID DECIMAL(5),
	TimesheetID DECIMAL(5),

	CONSTRAINT projecttimesheet_project_fk
	FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID),

	CONSTRAINT projecttimesheet_timesheet_fk
	FOREIGN KEY (TimesheetID) REFERENCES Timesheet(TimesheetID)
);

--Task Timesheet Contains Table
CREATE TABLE TaskTimesheet (
	TaskTimesheetID DECIMAL(5) PRIMARY KEY,
	TaskID DECIMAL(5),
	TimesheetID DECIMAL(5) NOT NULL,
	HoursWorked DECIMAL(5) NOT NULL

	CONSTRAINT tasktimesheet_task_fk
	FOREIGN KEY (TaskID) REFERENCES Task(TaskID),

	CONSTRAINT tasktimesheet_timesheet_fk
	FOREIGN KEY (TimesheetID) REFERENCES Timesheet(TimesheetID)
);

--Roles Table
CREATE TABLE Roles (
	RoleID DECIMAL(5) PRIMARY KEY,
	RoleName VARCHAR(50) NOT NULL
);

--Roles Resource Assignment Table
CREATE TABLE RolesResourceAssignment (
	RolesResourceAssignmentID DECIMAL(5) PRIMARY KEY,
	RoleID DECIMAL(5),
	EmployeeID DECIMAL(5),

	CONSTRAINT rolesresourceassignment_role_fk
	FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),

	CONSTRAINT rolesresourceassignment_resource_fk
	FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

--HISTORY TABLE to track changes in Project Estimated Hours
CREATE TABLE EstimatedHourChange (
	HoursChangeID DECIMAL(5) PRIMARY KEY,
	ProjectID DECIMAL(5),
	OldEstimatedProjectHours DECIMAL(10) NOT NULL,
	NewEstimatedProjectHours DECIMAL(10) NOT NULL,
	ChangeDate DATE NOT NULL

	CONSTRAINT project_id_fk
	FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);


--SEQUENCES
--Replace this with your sequence creations.
--All tables that need them should have an associated sequence.

CREATE SEQUENCE employee_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE project_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE timesheet_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE task_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE projectresourcesssociation_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE roles_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE rolesresourceassignment_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE tasktimesheet_seq START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE projecttimesheet_seq START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE estimatedhourchange_seq START WITH 1 INCREMENT BY 1;

--INDEXES
--Replace this with your index creations.
--Index to be created for all Foreign Keys for all tables without exception.

--Project Table Index
CREATE INDEX idx_project_pmemployee_id ON Project(PMEmployeeID);
CREATE INDEX idx_project_customer_id ON Project(CustomerID);

--Timesheet Table Index
CREATE INDEX idx_timesheet_resourceemployee_id ON Timesheet(ResourceEmployeeID);
CREATE INDEX idx_timesheet_pmemployee_id ON Timesheet(PMEmployeeID);

--ProjectTimesheet Table Index
CREATE INDEX idx_projecttimesheet_project_id ON ProjectTimesheet(ProjectID);
CREATE INDEX idx_projecttimesheet_timesheet_id ON ProjectTimesheet(TimesheetID);

--Task Timesheet Table Index
CREATE INDEX idx_tasktimesheet_task_id ON TaskTimesheet(TaskID);
CREATE INDEX idx_tasktimesheet_timesheet_id ON TaskTimesheet(TimesheetID);

--RoleResourceAssignment Table Index
CREATE INDEX idx_rolesresourceassignment_role_id ON RolesResourceAssignment(RoleID);
CREATE INDEX idx_rolesresourceassignment_employee_id ON RolesResourceAssignment(EmployeeID);

--ProjectResourceAssociation Table Index. Did not have this Iteration 5. Corrected here. 
CREATE INDEX idx_projectresourceassociation_project_id ON ProjectResourceAssociation(ProjectID);
CREATE INDEX idx_projectresourceassociation_resource_id ON ProjectResourceAssociation(ResourceEmployeeID);

--Custom Indexes

--TimesheetDate on Timesheet
CREATE INDEX idx_timesheet_timesheetdate ON Timesheet(TimesheetDate);

--Start Date on Project. Updated from IsBillable on Task
CREATE INDEX idx_project_startdate ON Project(StartDate);

--EstimatedEndDate on Project. Removed Project ID as it is already indexed. 
CREATE INDEX idx_project_projectid_estimatedenddate ON Project(EstimatedEndDate);


--STORED PROCEDURES
--Replace this with your stored procedure definitions.
--For all inserts in the stored procedures check the parameters are valid or not
--For all inserts in the stored procedures use transactions to ensure any improper transactions are rolled back.

--Employee Addition Procedure
CREATE PROCEDURE AddEmployee 
	@FirstName VARCHAR(50),
	@LastName VARCHAR(50),
	@EmployeeLocation VARCHAR(50)
AS
BEGIN

	/*Creating the username. The username is a concatenation of the first letter of the first name and full last name. Username is unique, therefore, if the same name username exists, 
	it gets appended with a number that sequentially increases starting from 2. For e.g. for Siddhant Nair, username is snair, and for Shantanu Nair, username is snair2, etc.*/
	DECLARE @Username VARCHAR(50)
	DECLARE @TempUsername VARCHAR(50)
	DECLARE @Count DECIMAL(10) = 2 --First duplicate username has a suffix 2: snair, snair2, snair3 and so on

	--Creating the username 
	SET @Username = LOWER(LEFT(@FirstName, 1) + @LastName)
	SET @TempUsername = @Username

	/*Using a While loop to iterate through exists table, that is for each positive exist, 
	the while loop does two things: concatenate the tempusername with the baseusername + count and then increases the count. 
	The next time the loop comes across the same username, the count will further increase sequentially */
	WHILE EXISTS (SELECT 1 FROM Employee WHERE UserName = @TempUsername) 
	--Returning value that match the tempusername. The tempusername is updated after each loop thus captures all matching usernames. When no matching username exists the loop stops.
	BEGIN
		SET @TempUsername = @Username + CAST(@Count AS VARCHAR)
		SET @Count = @Count + 1
	END
	
	--Assigning the tempusername as the main username
	SET @Username = @TempUsername

	--Inserting values into the Employees and Resources table. The Project Manager table is only populated when a new resource is added as a project manager for a new Project 
	DECLARE @EmployeeID DECIMAL(5) = NEXT VALUE FOR employee_seq --Employee ID will be the same for Employee and Resource tables

	--Employee Insert
	INSERT INTO Employee (EmployeeID, FirstName, LastName, UserName, EmployeeLocation)
	VALUES (@EmployeeID, @FirstName, @LastName, @Username, @EmployeeLocation)

	--Resource Insert
	INSERT INTO Resources(EmployeeID)
	VALUES (@EmployeeID)
END;


--Employee Addition Trigger: This will check that the first and last name of the employee does not contain numeric digits. 
CREATE TRIGGER trg_checkEmployeeName
ON Employee
AFTER INSERT, UPDATE
AS
BEGIN
	--Check if any of inserted or updated first or last name contain numeric digits
	IF EXISTS (
		SELECT 1
		FROM INSERTED 
			WHERE PATINDEX('%[0-9]%', FirstName) > 0
			OR PATINDEX('%[0-9]%', LastName) >0
	)
	BEGIN
		ROLLBACK TRANSACTION;

		--Raise error message
		RAISERROR('Invalid name: the first or the last name contains numeric digit. The transaction has been rolled back', 16, 1);
	END
END;


--Customer Addition Procedure
CREATE PROCEDURE AddCustomer
	@CustomerName VARCHAR(255), 
	@ContactFirstName VARCHAR(50), 
	@ContactLastName VARCHAR(50), 
	@DesignatedEmail VARCHAR(255), 
	@DesignatedPhone DECIMAL(10)
AS
BEGIN
	--Simple insert
	INSERT INTO Customer(CustomerID, CustomerName, ContactFirstName, ContactLastName, DesignatedEmail, DesignatedPhone)
	VALUES (NEXT VALUE FOR customer_seq, @CustomerName, @ContactFirstName, @ContactLastName, @DesignatedEmail, @DesignatedPhone)
END;

--Customer Addition Trigger: This will check that the first and last name of the customer contact does not contain numeric digits. 
CREATE TRIGGER trg_checkCustomerContactName
ON Customer
AFTER INSERT, UPDATE
AS
BEGIN
	--Check if any of inserted or updated first or last name contain numeric digits
	IF EXISTS (
		SELECT 1
		FROM INSERTED 
			WHERE PATINDEX('%[0-9]%', ContactFirstName) > 0
			OR PATINDEX('%[0-9]%', ContactLastName) >0
	)
	BEGIN
		ROLLBACK TRANSACTION;

		--Raise error message
		RAISERROR('Invalid name: the first or the last name contains numeric digit. The transaction has been rolled back', 16, 1);
	END
END;


--Project Addition Procedure
CREATE PROCEDURE CreateProject
	@PMEmployeeID DECIMAL(5),
	@CustomerID DECIMAL(5),
	@ProjectName VARCHAR(255),
	@ProjectDescription VARCHAR(255),
	@isTimeAndMaterial BIT,
	@EstimatedProjectHours DECIMAL(10),
	@ProjectCost DECIMAL(10),
	@StartDate DATE,
	@EstimatedEndDate DATE
AS
BEGIN
	--Simple insert into the Project table.
	DECLARE @ProjectID DECIMAL(5) = NEXT VALUE FOR project_seq;
	INSERT INTO Project(ProjectID, PMEmployeeID, CustomerID, ProjectName, ProjectDescription, isTimeAndMaterial, EstimatedProjectHours, ProjectCost, StartDate, EstimatedEndDate, ActualEndDate)
	VALUES(@ProjectID, @PMEmployeeID, @CustomerID, @ProjectName, @ProjectDescription, @isTimeAndMaterial, @EstimatedProjectHours, @ProjectCost, CAST(@StartDate AS DATE), CAST(@EstimatedEndDate AS DATE), NULL)

	--Check the value of the isTimeAndMaterial. If 0, add the line item to time and material, else add the line item to fixed bid.
	IF @isTimeAndMaterial = 0
	BEGIN
		INSERT INTO TimeMaterialProject(ProjectID)
		VALUES (@ProjectID)
	END
	
	ELSE
	BEGIN
		INSERT INTO FixedBidProject(ProjectID)
		VALUES(@ProjectID)
	END

	--Check if the project manager exists in the PM table. If not, then add him/her to the Project Manager table.
	IF NOT EXISTS (SELECT 1 FROM ProjectManager WHERE EmployeeID = @PMEmployeeID)
	BEGIN
		INSERT INTO ProjectManager(EmployeeID)
		VALUES (@PMEmployeeID)
	END
END;

/*Project Creation Trigger: This will ensure:
1. The estimated end date is not before (less than) the start date. 
2. The project hours is not negative or zero. 
3. If the isBillable is true (i.e. 1) then there needs to be an associated project cost.
4. If there is a project cost, it cannot be 0 or negative*/ 
CREATE TRIGGER trg_ValidateProject
ON Project
AFTER INSERT, UPDATE
AS 
BEGIN
	--Check if the estimated end date is not before the start date
	IF EXISTS (
		SELECT 1
		FROM INSERTED
		WHERE EstimatedEndDate < StartDate
	)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR('The estimated end date cannot be earlier than the start date', 16, 1)
		RETURN;
	END

	--Check the project hour is not negative or zero
	IF EXISTS (
		SELECT 1
		FROM INSERTED
		WHERE EstimatedProjectHours <= 0
	)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR('The projkect hours must be greater than zero', 16, 1)
		RETURN;
	END

	--Ensure there is a project cost if the project is of type fixed bid
	IF EXISTS(
		SELECT 1
		FROM INSERTED
		WHERE isTimeAndMaterial = 1
		AND ProjectCost = NULL
	)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR('A fixed bid project must have an associated cost', 16, 1)
		RETURN;
	END

	--Ensure that the project cost is not 0 or negative
	IF EXISTS(
		SELECT 1
		FROM INSERTED
		WHERE ProjectCost <= 0
	)
	BEGIN 
		ROLLBACK TRANSACTION;
		RAISERROR('The project cost cannot be 0 or negative', 16, 1)
		RETURN;
	END
END;


--Trigger to update history table to track changes in estimated hours
CREATE TRIGGER trg_UpdateEstimatedHourChangeTable
ON Project
AFTER UPDATE
AS
BEGIN
	DECLARE @OldHours DECIMAL(10) = (SELECT EstimatedProjectHours FROM DELETED);
	DECLARE @NewHours DECIMAL(10) = (SELECT EstimatedProjectHours FROM INSERTED);

	IF (@OldHours <> @NewHours)
	BEGIN
		INSERT INTO EstimatedHourChange(HoursChangeID, ProjectID, OldEstimatedProjectHours, NewEstimatedProjectHours, ChangeDate)
		VALUES (NEXT VALUE FOR estimatedhourchange_seq, (SELECT ProjectID FROM INSERTED), @OldHours, @NewHours, GETDATE())
	END
END;

--Project Closure Procedure
CREATE PROCEDURE CloseProject
	@PMEmployeeID DECIMAL(5),
	@ProjectID DECIMAL(5),
	@ActualEndDate DATE
AS
BEGIN
	DECLARE @ActualPMEmployeeID DECIMAL(5) 
	SELECT @ActualPMEmployeeID = PMEmployeeID
	FROM Project
	WHERE ProjectID = @ProjectID;

	IF @ActualPMEmployeeID != @PMEmployeeID
	BEGIN
		RAISERROR('Only the assigned project manager can close the project', 16, 1)
		RETURN
	END

	--Adding a check to ensure that the actual end date is not greater today's date. A PM should not be able to close the project on the basis of an expected sign off.
	--Did not make this as a separate trigger as to not affect the trg_ValidateProject trigger as that is also triggered after an update.
	IF @ActualEndDate > GETDATE()
	BEGIN
		RAISERROR('The actual end date cannot be in the future', 16, 1)
		RETURN
	END

	UPDATE Project
	SET ActualEndDate = CAST(@ActualEndDate AS DATE)
	WHERE Project.ProjectID = @ProjectID
END
	

--Task Addition Procedure
CREATE PROCEDURE AddTask
	@TaskName VARCHAR(255),
	@isBillable BIT
AS
BEGIN
	--Simple insert to Task
	DECLARE @TaskID DECIMAL(5) = NEXT VALUE FOR task_seq
	INSERT INTO Task (TaskID, TaskName, IsBillable)
	VALUES (@TaskID, @TaskName, @isBillable)

	--Add the entry to Billable/Non-Billable table based on isBillable
	IF @isBillable = 0
	BEGIN
		INSERT INTO BillableTask(TaskID)
		VALUES (@TaskID)
	END

	ELSE
	BEGIN
		INSERT INTO NonBillableTask(TaskID)
		VALUES (@TaskID)
	END
END;

--Timesheet Addition Procedure
CREATE PROCEDURE AddTimesheetEntry
	@ResourceEmployeeID DECIMAL(5),
	@PMEmployeeID DECIMAL(5),
	@TimesheetDate DATE,
	@ProjectID DECIMAL(5),
	@TaskID DECIMAL(5),
	@HoursWorked DECIMAL(5)
AS 
BEGIN
	
	--Validating that the PMEmployeeID is actually the PM of the given Project
	DECLARE @ActualPMEmployeeID DECIMAL (5) --Will store the actual Employee ID of the project manager

	SELECT @ActualPMEmployeeID = PMEmployeeID
	FROM PROJECT
	WHERE ProjectID = @ProjectID
	
	IF @ActualPMEmployeeID != @PMEmployeeID
	BEGIN
		RAISERROR('Invalid Project Manager for the specified Project.', 16, 1)
		RETURN
	END


	--Validating that the resource is associated with the project
	DECLARE @IsResoruceAssociated BIT --True/False if the resource is associated with the project
	
	SELECT @IsResoruceAssociated = 
	CASE WHEN EXISTS (
		SELECT 1
		FROM ProjectResourceAssociation
		WHERE ProjectID = @ProjectID
		AND ResourceEmployeeID = @ResourceEmployeeID
	) THEN 1 
	ELSE 0
	END

	--Checking True/False
	IF @IsResoruceAssociated = 0
	BEGIN
		RAISERROR('Resource is not associated with the given project', 16, 1)
		RETURN
	END


	--Validating that project does not have an actual end date
	--This validation was added after the historical data was populated. This was so that closed projects could also had hours associated.
	
	DECLARE @ActualEndDate DATE

	SELECT @ActualEndDate = ActualEndDate
	FROM Project
	WHERE ProjectID = @ProjectID

	IF @ActualEndDate IS NOT NULL
	BEGIN
		RAISERROR('Hours cannot be entered for Projects that are closed.', 16, 1)
		RETURN
	END
	

	--Required validations complete. Entering the required data.
	DECLARE @TimesheetID DECIMAL(5) = NEXT VALUE FOR timesheet_seq
	DECLARE @ProjectTimesheetID DECIMAL(5) = NEXT VALUE FOR projecttimesheet_seq
	DECLARE @TaskTimesheetID DECIMAL(5) = NEXT VALUE FOR tasktimesheet_seq


	--Inserting values into the timesheet table
	INSERT INTO Timesheet(TimesheetID, ResourceEmployeeID, PMEmployeeID, TimesheetDate, SubmittedDate, IsApproved, ApprovedDate)
	VALUES (@TimesheetID, @ResourceEmployeeID, @PMEmployeeID, CAST(@TimesheetDate AS DATE), GETDATE(), 0, NULL)

	--Inserting values into the project timesheet association table
	INSERT INTO ProjectTimesheet (ProjectTimesheetID, ProjectID, TimesheetID)
	VALUES (@ProjectTimesheetID, @ProjectID, @TimesheetID)

	--Inserting values into the task timesheet table
	INSERT INTO TaskTimesheet (TaskTimesheetID, TaskID, TimesheetID, HoursWorked)
	VALUES (@TaskTimesheetID, @TaskID, @TimesheetID, @HoursWorked)

END;

DROP TRIGGER trg_ValidateTimesheetDate;
--Timesheet addition trigger: To ensure that the timesheet date is not greater than the submitted date
--Trigger was executed after the historical data was added
CREATE TRIGGER trg_ValidateTimesheetDate
ON Timesheet
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM INSERTED
		WHERE TimesheetDate <= SubmittedDate --Submitted Date is already GETDATE()
	)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR('The timesheet date cannot be greater than submitted date', 16, 1)
		RETURN;
	END

END


--Timesheet Approval Procedure
CREATE PROCEDURE TimesheetApproval
	@PMEmployeeID DECIMAL(5),
	@TimesheetID DECIMAL (5)
AS
BEGIN
	DECLARE @ActualPMEmployeeID DECIMAL (5) 
	
	--Getting the employee ID of the PM that was associated with the timesheet. No need to validate the PM here as its already validated when adding the timesheet
	SELECT @ActualPMEmployeeID = PMEmployeeID 
	FROM Timesheet
	WHERE Timesheet.TimesheetID = @TimesheetID

	--Updating the approval information for the timesheet id if the project manager ID matches.
	IF @ActualPMEmployeeID = @PMEmployeeID
	BEGIN
		UPDATE Timesheet
		SET IsApproved = 1,
		ApprovedDate = GETDATE()
		WHERE TimesheetID = @TimesheetID
	END

	ELSE
	BEGIN
		RAISERROR('The Project Manager is not associated with the given timesheet', 16, 1)
		RETURN
	END
END;


--Procedure to link Resources with Projects
CREATE PROCEDURE AddResourceToProject
	@ProjectID DECIMAL(5),
	@ResourceEmployeeID DECIMAL(5)
AS
BEGIN
	DECLARE @AssociationID DECIMAL(5) = NEXT VALUE FOR projectresourcesssociation_seq

	INSERT INTO ProjectResourceAssociation(AssociationID, ProjectID, ResourceEmployeeID)
	VALUES (@AssociationID, @ProjectID, @ResourceEmployeeID)
END;


--Procedure to link Resources with Roles
CREATE PROCEDURE AddRolesToResources
	@RoleID DECIMAL(5),
	@EmployeeID DECIMAL(5)
AS 
BEGIN
	DECLARE @RolesResourceAssignmentID DECIMAL(5) = NEXT VALUE FOR rolesresourceassignment_seq

	INSERT INTO RolesResourceAssignment (RolesResourceAssignmentID, RoleID, EmployeeID)
	VALUES (@RolesResourceAssignmentID, @RoleID, @EmployeeID)
END;


--INSERTS
--Replace this with the inserts necessary to populate your tables.
--Some of these inserts will come from executing the stored procedures.

--Inserting values into Roles. Limited rows that dont often change thus did not create a procedure.
INSERT INTO Roles(RoleID, RoleName)
VALUES (NEXT VALUE FOR roles_seq, 'Business Analyst');

INSERT INTO Roles(RoleID, RoleName)
VALUES (NEXT VALUE FOR roles_seq, 'Solution Architect');

INSERT INTO Roles(RoleID, RoleName)
VALUES (NEXT VALUE FOR roles_seq, 'Developer');

INSERT INTO Roles(RoleID, RoleName)
VALUES (NEXT VALUE FOR roles_seq, 'Quality Assurance Analyst');

INSERT INTO Roles(RoleID, RoleName)
VALUES (NEXT VALUE FOR roles_seq, 'Infrastructure Engineer');

SELECT *
FROM Roles;


--Inserting values into Tasks, including Billable and Non Billable.
BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Discovery', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Requirements Analysis', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Documentation', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Solution Design', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Development', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Quality Assurance and Testing', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Deployment', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Hypercare', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Infrastructure/Application Provisioning', 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Sick', 1;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Holiday', 1;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddTask;
EXECUTE AddTask 'Jury Duty', 1;
COMMIT TRANSACTION;

SELECT *
FROM Task;

SELECT *
FROM BillableTask;

SELECT *
FROM NonBillableTask;

--Inserting values into Employees, including Resources.
--Adding one entry to check accuracy
BEGIN TRANSACTION AddEmployee;
EXECUTE AddEmployee 'Siddhant', 'Nair', 'USA';
COMMIT TRANSACTION;

BEGIN TRANSACTION AddEmployee;
EXECUTE AddEmployee 'Varun', 'Bhatia', 'INDIA';
COMMIT TRANSACTION;

BEGIN TRANSACTION AddEmployee;
EXECUTE AddEmployee 'Gavin', 'Yu', 'USA';
COMMIT TRANSACTION;

BEGIN TRANSACTION AddEmployee;
EXECUTE AddEmployee 'Franklin', 'Rodriguez', 'USA';
COMMIT TRANSACTION;

BEGIN TRANSACTION AddEmployee;
EXECUTE AddEmployee 'Tushar', 'Kapoor', 'INDIA';
COMMIT TRANSACTION;

BEGIN TRANSACTION AddEmployee;
EXECUTE AddEmployee 'Shantanu', 'Nair', 'USA';
COMMIT TRANSACTION;

SELECT *
FROM Employee;

SELECT *
FROM Resources;

--Inserting values into RolesResourceAssignment.
BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 1, 1;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 2, 2;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 3, 2;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 4, 2;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 1, 3;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 3, 4;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 4, 4;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 3, 5;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 4, 5;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 2, 6;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 3, 6;
COMMIT TRANSACTION;

BEGIN TRANSACTION AddRolesToResources;
EXECUTE AddRolesToResources 4, 6;
COMMIT TRANSACTION;

SELECT *
FROM RolesResourceAssignment;

--Inserting values into Customer.
BEGIN TRANSACTION AddCustomer;
EXECUTE AddCustomer 'Northwell Health', 'Angie', 'Kemp', 'akemp@northwell.edu', '5164666655';
COMMIT TRANSACTION;

BEGIN TRANSACTION AddCustomer;
EXECUTE AddCustomer 'Presidio Corp', 'John', 'Popowitch', 'jpopowitch@presidio.com', '5168667250';
COMMIT TRANSACTION;

BEGIN TRANSACTION AddCustomer;
EXECUTE AddCustomer 'Nassau County', 'Daniel', 'Looney', 'danlooney@nassau.gov', '5162524550';
COMMIT TRANSACTION;

SELECT *
FROM Customer;


--Inserting values into Project, including Project Manager, Fixed Bid and Time and Material. --Adding some additional entries since iteration 5. Used ChatGPT to generate the transactions.
BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 6,
    @CustomerID = 1,
    @ProjectName = 'Northwell AP/AR',
    @ProjectDescription = 'Reconciliation process for Northwell Health',
    @isTimeAndMaterial = 1,
    @EstimatedProjectHours = 240,
    @ProjectCost = 30000,
    @StartDate = '2020-05-06',
    @EstimatedEndDate = '2020-06-03';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 2,
    @CustomerID = 3,
    @ProjectName = 'BWC Transfer',
    @ProjectDescription = 'Transferring Body Worn Camera file to internal Nassau application',
    @isTimeAndMaterial = 0,
    @EstimatedProjectHours = 320,
    @ProjectCost = NULL,
    @StartDate = '2021-08-01',
    @EstimatedEndDate = '2021-09-27';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 6,
    @CustomerID = 1,
    @ProjectName = 'Northwell Requisition',
    @ProjectDescription = 'IT Procurement automation for Northwell',
    @isTimeAndMaterial = 1,
    @EstimatedProjectHours = 240,
    @ProjectCost = 30000,
    @StartDate = '2022-05-10',
    @EstimatedEndDate = '2022-06-07';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 1,
    @CustomerID = 2,
    @ProjectName = 'Microsoft Billing',
    @ProjectDescription = 'Create billing line items and then add them to the invoice',
    @isTimeAndMaterial = 0,
    @EstimatedProjectHours = 360,
    @ProjectCost = NULL,
    @StartDate = '2024-08-19',
    @EstimatedEndDate = '2024-10-21';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 2,
    @CustomerID = 3,
    @ProjectName = 'DWI Transfer',
    @ProjectDescription = 'Transfer video recordings of suspects from a network folder to the case management system for the given case',
    @isTimeAndMaterial = 1,
    @EstimatedProjectHours = 280,
    @ProjectCost = 35000,
    @StartDate = '2024-08-18',
    @EstimatedEndDate = '2024-10-06';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 6,
    @CustomerID = 1,
    @ProjectName = 'Automatic Procedure Coding',
    @ProjectDescription = 'Automatically code the procedure for billing based on CPT standards',
    @isTimeAndMaterial = 0,
    @EstimatedProjectHours = 560,
    @ProjectCost = NULL,
    @StartDate = '2024-08-28',
    @EstimatedEndDate = '2024-12-04';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 6,
    @CustomerID = 1,
    @ProjectName = 'Collating Patient Information',
    @ProjectDescription = 'Collate all health-related data from various systems for a given customer in a network drive',
    @isTimeAndMaterial = 0,
    @EstimatedProjectHours = 480,
    @ProjectCost = NULL,
    @StartDate = '2024-09-07',
    @EstimatedEndDate = '2024-11-30';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 6,
    @CustomerID = 1,
    @ProjectName = 'Vendor COI Verification',
    @ProjectDescription = 'Reach out to vendors with expiring Certificate of Insurance and request for an updated COI. Process and validate the incoming COI for any business rule exception and reach out or update the COI database.',
    @isTimeAndMaterial = 0,
    @EstimatedProjectHours = 360,
    @ProjectCost = NULL,
    @StartDate = '2024-09-17',
    @EstimatedEndDate = '2024-11-19';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 1,
    @CustomerID = 2,
    @ProjectName = 'Non-B2b Robot',
    @ProjectDescription = 'Process invoices received via email into the ERP system',
    @isTimeAndMaterial = 0,
    @EstimatedProjectHours = 360,
    @ProjectCost = NULL,
    @StartDate = '2024-09-28',
    @EstimatedEndDate = '2024-11-30';
COMMIT TRANSACTION;

BEGIN TRANSACTION;
EXECUTE CreateProject 
    @PMEmployeeID = 2,
    @CustomerID = 3,
    @ProjectName = 'MetaData Robot',
    @ProjectDescription = 'Capture metadata for new cases in the case management system',
    @isTimeAndMaterial = 1,
    @EstimatedProjectHours = 400,
    @ProjectCost = 50000,
    @StartDate = '2024-10-17',
    @EstimatedEndDate = '2024-12-26';
COMMIT TRANSACTION;

SELECT*
FROM Project;

--Procedures to close some of the projects
BEGIN TRANSACTION CloseProject;
EXECUTE CloseProject 6, 1, '06/10/2020';
COMMIT TRANSACTION;

BEGIN TRANSACTION CloseProject;
EXECUTE CloseProject 2, 2, '09/27/2021';
COMMIT TRANSACTION;

BEGIN TRANSACTION CloseProject;
EXECUTE CloseProject 6, 3, '06/14/2022';
COMMIT TRANSACTION;

--Purposefully wrong entry. Entering the wrong project manager detail here, this should throw an error.
BEGIN TRANSACTION CloseProject;
EXECUTE CloseProject 1, 2, '06/14/2024';
COMMIT TRANSACTION;

SELECT *
FROM Project;

SELECT *
FROM ProjectManager;

SELECT *
FROM FixedBidProject;

SELECT *
FROM TimeMaterialProject;


--Inserting values into ProjectResourceAssociation
-- Project 1: PMEmployeeID = 6
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 1, @ResourceEmployeeID = 1;
-- Role 2 (Resource 2)
EXECUTE AddResourceToProject @ProjectID = 1, @ResourceEmployeeID = 2;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 1, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 1, @ResourceEmployeeID = 4;
COMMIT TRANSACTION;

-- Project 2: PMEmployeeID = 2
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 2, @ResourceEmployeeID = 1;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 2, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 2, @ResourceEmployeeID = 4;
-- Role 5 (Resource 5)
EXECUTE AddResourceToProject @ProjectID = 2, @ResourceEmployeeID = 5;
COMMIT TRANSACTION;

-- Project 3: PMEmployeeID = 6
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 3, @ResourceEmployeeID = 1;
-- Role 2 (Resource 2)
EXECUTE AddResourceToProject @ProjectID = 3, @ResourceEmployeeID = 2;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 3, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 3, @ResourceEmployeeID = 4;
COMMIT TRANSACTION;

-- Project 4: PMEmployeeID = 1
BEGIN TRANSACTION;
-- Role 2 (Resource 2)
EXECUTE AddResourceToProject @ProjectID = 4, @ResourceEmployeeID = 2;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 4, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 4, @ResourceEmployeeID = 4;
-- Role 5 (Resource 5)
EXECUTE AddResourceToProject @ProjectID = 4, @ResourceEmployeeID = 5;
COMMIT TRANSACTION;

-- Project 5: PMEmployeeID = 1
BEGIN TRANSACTION;
-- Role 2 (Resource 2)
EXECUTE AddResourceToProject @ProjectID = 5, @ResourceEmployeeID = 2;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 5, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 5, @ResourceEmployeeID = 4;
-- Role 5 (Resource 5)
EXECUTE AddResourceToProject @ProjectID = 5, @ResourceEmployeeID = 5;
COMMIT TRANSACTION;

-- Project 6: PMEmployeeID = 2
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 6, @ResourceEmployeeID = 1;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 6, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 6, @ResourceEmployeeID = 4;
-- Role 5 (Resource 5)
EXECUTE AddResourceToProject @ProjectID = 6, @ResourceEmployeeID = 5;
COMMIT TRANSACTION;

-- Project 7: PMEmployeeID = 2
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 7, @ResourceEmployeeID = 1;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 7, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 7, @ResourceEmployeeID = 4;
-- Role 5 (Resource 5)
EXECUTE AddResourceToProject @ProjectID = 7, @ResourceEmployeeID = 5;
COMMIT TRANSACTION;

-- Project 8: PMEmployeeID = 6
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 8, @ResourceEmployeeID = 1;
-- Role 2 (Resource 2)
EXECUTE AddResourceToProject @ProjectID = 8, @ResourceEmployeeID = 2;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 8, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 8, @ResourceEmployeeID = 4;
COMMIT TRANSACTION;

-- Project 9: PMEmployeeID = 6
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 9, @ResourceEmployeeID = 1;
-- Role 2 (Resource 2)
EXECUTE AddResourceToProject @ProjectID = 9, @ResourceEmployeeID = 2;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 9, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 9, @ResourceEmployeeID = 4;
COMMIT TRANSACTION;

-- Project 10: PMEmployeeID = 6
BEGIN TRANSACTION;
-- Role 1 (Resource 1)
EXECUTE AddResourceToProject @ProjectID = 10, @ResourceEmployeeID = 1;
-- Role 2 (Resource 2)
EXECUTE AddResourceToProject @ProjectID = 10, @ResourceEmployeeID = 2;
-- Role 3 (Resource 3)
EXECUTE AddResourceToProject @ProjectID = 10, @ResourceEmployeeID = 3;
-- Role 4 (Resource 4)
EXECUTE AddResourceToProject @ProjectID = 10, @ResourceEmployeeID = 4;
COMMIT TRANSACTION;

SELECT *
FROM Project;

SELECT *
FROM ProjectResourceAssociation;

--Created this query to ensure that the ChatGPT generated entries matched up
SELECT Project.ProjectID, 
Project.ProjectName,
Project.PMEmployeeID,
Employee.EmployeeID,
Employee.FirstName,
Customer.CustomerName,
Roles.RoleName
FROM ProjectResourceAssociation
JOIN Project ON ProjectResourceAssociation.ProjectID = Project.ProjectID
JOIN Resources ON ProjectResourceAssociation.ResourceEmployeeID = Resources.EmployeeID
JOIN Employee ON Resources.EmployeeID = Employee.EmployeeID
JOIN Customer ON Project.CustomerID = Customer.CustomerID
JOIN RolesResourceAssignment ON Resources.EmployeeID = RolesResourceAssignment.EmployeeID
JOIN Roles ON RolesResourceAssignment.RoleID = Roles.RoleID;

--Inserting values into Timesheet

-- Project 1 (Northwell AP/AR) -- PMEmployeeID = 6
BEGIN TRANSACTION;
-- Resource 1 (Business Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 1,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 1,
    @TaskID = 1, -- Discovery
    @HoursWorked = 8;
-- Resource 2 (Solution Architect)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 2,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 1,
    @TaskID = 4, -- Solution Design
    @HoursWorked = 7;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 1,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 1,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
COMMIT TRANSACTION;

-- Project 2 (BWC Transfer) -- PMEmployeeID = 2
BEGIN TRANSACTION;
-- Resource 1 (Business Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 1,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 2,
    @TaskID = 1, -- Discovery
    @HoursWorked = 8;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 2,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 2,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
-- Resource 5 (Infrastructure Engineer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 5,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 2,
    @TaskID = 9, -- Infrastructure Provisioning
    @HoursWorked = 6;
COMMIT TRANSACTION;

-- Project 3 (Northwell Requisition) -- PMEmployeeID = 6
BEGIN TRANSACTION;
-- Resource 1 (Business Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 1,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 3,
    @TaskID = 2, -- Requirement Analysis
    @HoursWorked = 8;
-- Resource 2 (Solution Architect)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 2,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 3,
    @TaskID = 4, -- Solution Design
    @HoursWorked = 7;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 3,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 3,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
COMMIT TRANSACTION;

-- Project 4 (Non-B2b Robot) -- PMEmployeeID = 1
BEGIN TRANSACTION;
-- Resource 2 (Solution Architect)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 2,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 4,
    @TaskID = 4, -- Solution Design
    @HoursWorked = 7;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 4,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 4,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
-- Resource 5 (Infrastructure Engineer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 5,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 4,
    @TaskID = 9, -- Infrastructure Provisioning
    @HoursWorked = 6;
COMMIT TRANSACTION;

-- Project 5 (DWI Transfer) -- PMEmployeeID = 2
BEGIN TRANSACTION;
-- Resource 2 (Solution Architect)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 2,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 5,
    @TaskID = 4, -- Solution Design
    @HoursWorked = 7;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 5,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 5,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
-- Resource 5 (Infrastructure Engineer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 5,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 5,
    @TaskID = 9, -- Infrastructure Provisioning
    @HoursWorked = 6;
COMMIT TRANSACTION;

-- Project 6 (Automatic Procedure Coding) -- PMEmployeeID = 6
BEGIN TRANSACTION;
-- Resource 1 (Business Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 1,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 6,
    @TaskID = 2, -- Requirement Analysis
    @HoursWorked = 8;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 6,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 6,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
-- Resource 5 (Infrastructure Engineer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 5,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 6,
    @TaskID = 9, -- Infrastructure Provisioning
    @HoursWorked = 6;
COMMIT TRANSACTION;

-- Project 7 (Collating Patient Information) -- PMEmployeeID = 6
BEGIN TRANSACTION;
-- Resource 1 (Business Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 1,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 7,
    @TaskID = 2, -- Requirement Analysis
    @HoursWorked = 8;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 7,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 7,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
-- Resource 5 (Infrastructure Engineer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 5,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 7,
    @TaskID = 9, -- Infrastructure Provisioning
    @HoursWorked = 6;
COMMIT TRANSACTION;

-- Project 8 (Vendor COI Verification) -- PMEmployeeID = 6
BEGIN TRANSACTION;
-- Resource 1 (Business Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 1,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 8,
    @TaskID = 1, -- Discovery
    @HoursWorked = 8;
-- Resource 2 (Solution Architect)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 2,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 8,
    @TaskID = 4, -- Solution Design
    @HoursWorked = 7;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 8,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 6,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 8,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
COMMIT TRANSACTION;

-- Project 9 (Non-B2b Robot) -- PMEmployeeID = 1
BEGIN TRANSACTION;
-- Resource 2 (Solution Architect)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 2,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 9,
    @TaskID = 4, -- Solution Design
    @HoursWorked = 7;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 9,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 9,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
-- Resource 5 (Infrastructure Engineer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 1,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 9,
    @TaskID = 9, -- Infrastructure Provisioning
    @HoursWorked = 6;
COMMIT TRANSACTION;

-- Project 10 (MetaData Robot) -- PMEmployeeID = 2
BEGIN TRANSACTION;
-- Resource 1 (Business Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 1,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 10,
    @TaskID = 2, -- Requirement Analysis
    @HoursWorked = 8;
-- Resource 3 (Developer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 3,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 10,
    @TaskID = 5, -- Development
    @HoursWorked = 6;
-- Resource 4 (QA Analyst)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 10,
    @TaskID = 6, -- QA and Testing
    @HoursWorked = 5;
-- Resource 5 (Infrastructure Engineer)
EXEC AddTimesheetEntry
    @ResourceEmployeeID = 4,
    @PMEmployeeID = 2,
    @TimesheetDate = '2024-10-13',
    @ProjectID = 10,
    @TaskID = 9, -- Infrastructure Provisioning
    @HoursWorked = 6;
COMMIT TRANSACTION;

SELECT *
FROM Timesheet;

SELECT *
FROM ProjectTimesheet;

SELECT *
FROM TaskTimesheet;


--Approving 2 Timesheets
BEGIN TRANSACTION ApproveTimesheet;
EXECUTE TimesheetApproval 1, 33;
COMMIT TRANSACTION;

BEGIN TRANSACTION ApproveTimesheet;
EXECUTE TimesheetApproval 6, 30;
COMMIT TRANSACTION;

--Wrong Input
BEGIN TRANSACTION ApproveTimesheet;
EXECUTE TimesheetApproval 6, 27;
COMMIT TRANSACTION;


--Changing a project estimated hour and then showcasing the history table
UPDATE Project
SET EstimatedProjectHours = 400
WHERE ProjectID = 4;

SELECT *
FROM EstimatedHourChange;

--QUERIES
--Replace this with your queries.

/*
How many hours has a particular resource has worked on the variety of projects he/she is associated with. What is the split between billable and non billable hours?
*/
SELECT 
    E.FirstName, 
    E.LastName, 
    SUM(CASE WHEN T.IsBillable = 0 THEN TT.HoursWorked ELSE 0 END) AS BillableHours, 
    SUM(CASE WHEN T.IsBillable = 1 THEN TT.HoursWorked ELSE 0 END) AS NonBillableHours
FROM 
    TaskTimesheet TT
JOIN 
    Timesheet TS ON TT.TimesheetID = TS.TimesheetID
JOIN 
    Task T ON TT.TaskID = T.TaskID
JOIN 
    Resources R ON TS.ResourceEmployeeID = R.EmployeeID
JOIN 
    Employee E ON R.EmployeeID = E.EmployeeID
GROUP BY 
    E.FirstName, E.LastName;


/*
Identify if any of the resources are working over 40 hours across all the projects to ensure that no one is overburdened with tasks.
*/
SELECT 
    E.FirstName, 
    E.LastName, 
    DATEPART(WEEK, TS.TimesheetDate) AS WeekNumber, 
    DATEPART(YEAR, TS.TimesheetDate) AS Year,
    SUM(TT.HoursWorked) AS TotalHoursWorked
FROM 
    TaskTimesheet TT
JOIN 
    Timesheet TS ON TT.TimesheetID = TS.TimesheetID
JOIN 
    Resources R ON TS.ResourceEmployeeID = R.EmployeeID
JOIN 
    Employee E ON R.EmployeeID = E.EmployeeID
GROUP BY 
    E.FirstName, 
    E.LastName, 
    DATEPART(WEEK, TS.TimesheetDate), 
    DATEPART(YEAR, TS.TimesheetDate)
ORDER BY 
    TotalHoursWorked DESC;


/*
Order the project managers by the net value of the projects they are handling. If the cost of the project is unavailable, then use the estimated hours to calculate the project cost using the dollar figure of $125/hr. Order by descending project cost.
*/
SELECT 
    pm.EmployeeID,
    e.FirstName,
    e.LastName,
    SUM(COALESCE(p.ProjectCost, p.EstimatedProjectHours * 125)) AS NetProjectValue
FROM 
    ProjectManager pm
JOIN 
    Employee e ON pm.EmployeeID = e.EmployeeID
JOIN 
    Project p ON pm.EmployeeID = p.PMEmployeeID
GROUP BY 
    pm.EmployeeID, e.FirstName, e.LastName
ORDER BY 
    NetProjectValue DESC;

/*
Data Visualization Query: It is important to compare and contrast the estimated hours against the actual hours. To calculate this we would compare the estimated hours against the actual hours. To calculate the actual
hours we would multiply the weeks elasped by 40 and compare the outputs for each project. For ongoing projects, we will compare how many hours we have utilized thus far for the given project.

Please note much of the data is development data at the moment.
*/
WITH ProjectHours AS (
    SELECT 
        P.ProjectID,
        P.ProjectName,
        P.EstimatedProjectHours,
        -- Calculate the total elapsed hours based on whether the project is closed or ongoing
        CASE 
            WHEN P.ActualEndDate IS NOT NULL THEN DATEDIFF(WEEK, P.StartDate, P.ActualEndDate) * 40 -- Closed projects
            ELSE DATEDIFF(WEEK, P.StartDate, GETDATE()) * 40 -- Ongoing projects
        END AS TotalElapsedHours
    FROM 
        Project P
)
SELECT 
    PH.ProjectID,
    PH.ProjectName,
    PH.EstimatedProjectHours,
    PH.TotalElapsedHours AS EstimatedElapsedHours,
    -- Calculate the difference between estimated elapsed hours and estimated project hours
    PH.EstimatedProjectHours - PH.TotalElapsedHours AS HoursDifference
FROM 
    ProjectHours PH
ORDER BY 
    PH.ProjectID;



--With appraisals right around the corner it is important to find out the employees that are underperforming. As such the following query tracks employee productivity by comparing the total hours logged with the number of tasks completed across RPA projects.
WITH EmployeeProductivity AS (
    SELECT 
        E.EmployeeID,
        E.FirstName + ' ' + E.LastName AS EmployeeName,
        COUNT(T.TaskID) AS TasksCompleted,
        SUM(TT.HoursWorked) AS TotalHoursLogged -- Sum the actual hours worked from the Timesheet
    FROM 
        Employee E
    INNER JOIN Resources R ON E.EmployeeID = R.EmployeeID
    INNER JOIN ProjectResourceAssociation PRA ON R.EmployeeID = PRA.ResourceEmployeeID
    INNER JOIN ProjectTimesheet PT ON PRA.ProjectID = PT.ProjectID
    INNER JOIN Timesheet TS ON PT.TimesheetID = TS.TimesheetID
	INNER JOIN TaskTimesheet TT ON TS.TimesheetID = TT.TimesheetID
    INNER JOIN Task T ON TT.TaskID = T.TaskID
    GROUP BY 
        E.EmployeeID, E.FirstName, E.LastName
)
SELECT 
    EmployeeID,
    EmployeeName,
    TasksCompleted,
    TotalHoursLogged,
    CASE 
        WHEN TotalHoursLogged > (TasksCompleted * 8) THEN 'Underperforming'
        ELSE 'Efficient'
    END AS PerformanceStatus
FROM 
    EmployeeProductivity
ORDER BY 
    PerformanceStatus DESC;





--Drop Table Commands
DROP TABLE Employee;
DROP TABLE Resources;
DROP TABLE ProjectManager;
DROP TABLE Customer;
DROP TABLE Project;
DROP TABLE FixedBidProject;
DROP TABLE TimeMaterialProject;
DROP TABLE ProjectResourceAssociation;
DROP TABLE Task;
DROP TABLE BillableTask;
DROP TABLE NonBillableTask;
DROP TABLE Timesheet;
DROP TABLE ProjectTimesheet;
DROP TABLE TaskTimesheet;
DROP TABLE Roles;
DROP TABLE RolesResourceAssignment;


--Drop Sequence Commands
DROP SEQUENCE employee_seq;
DROP SEQUENCE customer_seq;
DROP SEQUENCE project_seq;
DROP SEQUENCE timesheet_seq;
DROP SEQUENCE task_seq;
DROP SEQUENCE projectresourcesssociation_seq;
DROP SEQUENCE roles_seq;
DROP SEQUENCE rolesresourceassignment_seq;
DROP SEQUENCE tasktimesheet_seq; 
DROP SEQUENCE projecttimesheet_seq; 


--Drop Procedure Commands
DROP PROCEDURE AddEmployee;
DROP PROCEDURE AddCustomer;
DROP PROCEDURE CreateProject;
DROP PROCEDURE CloseProject;
DROP PROCEDURE AddTask;
DROP PROCEDURE AddTimesheetEntry;
DROP PROCEDURE TimesheetApproval;
DROP PROCEDURE AddResourceToProject;
DROP PROCEDURE AddRolesToResources;

--Drop Indexes Commands
DROP INDEX Resources.idx_resources_employee_id; --Indexing primary key. Not needed.
DROP INDEX ProjectManager.idx_projectmanager_employee_id; --Indexing primary key. Not needed. 
DROP INDEX Project.idx_project_pmemployee_id;
DROP INDEX Project.idx_project_customer_id;
DROP INDEX Timesheet.idx_timesheet_resourceemployee_id;
DROP INDEX Timesheet.idx_timesheet_pmemployee_id;
DROP INDEX ProjectTimesheet.idx_projecttimesheet_project_id;
DROP INDEX ProjectTimesheet.idx_projecttimesheet_timesheet_id;
DROP INDEX TaskTimesheet.idx_tasktimesheet_task_id;
DROP INDEX TaskTimesheet.idx_tasktimesheet_timesheet_id;
DROP INDEX RolesResourcesAssignment.idx_rolesresourceassignment_role_id;
DROP INDEX RolesResourcesAssignment.idx_rolesresourceassignment_employee_id;
DROP INDEX Timesheet.idx_timesheet_timesheetdate;
DROP INDEX Task.idx_task_isbillable; --Replace with something that doesnt conform to a limited set of values
DROP INDEX Project.idx_project_projectid_estimatedenddate;