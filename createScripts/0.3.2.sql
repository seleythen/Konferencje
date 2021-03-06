USE [master]
GO
/****** Object:  Database [rmucha_a]    Script Date: 20.01.2018 10:19:25 ******/
CREATE DATABASE [rmucha_a]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'rmucha_a', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\rmucha_a.mdf' , SIZE = 10240KB , MAXSIZE = 30720KB , FILEGROWTH = 2048KB )
 LOG ON 
( NAME = N'rmucha_a_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\rmucha_a.ldf' , SIZE = 10240KB , MAXSIZE = 30720KB , FILEGROWTH = 2048KB )
GO
ALTER DATABASE [rmucha_a] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [rmucha_a].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [rmucha_a] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [rmucha_a] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [rmucha_a] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [rmucha_a] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [rmucha_a] SET ARITHABORT OFF 
GO
ALTER DATABASE [rmucha_a] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [rmucha_a] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [rmucha_a] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [rmucha_a] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [rmucha_a] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [rmucha_a] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [rmucha_a] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [rmucha_a] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [rmucha_a] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [rmucha_a] SET  ENABLE_BROKER 
GO
ALTER DATABASE [rmucha_a] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [rmucha_a] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [rmucha_a] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [rmucha_a] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [rmucha_a] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [rmucha_a] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [rmucha_a] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [rmucha_a] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [rmucha_a] SET  MULTI_USER 
GO
ALTER DATABASE [rmucha_a] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [rmucha_a] SET DB_CHAINING OFF 
GO
ALTER DATABASE [rmucha_a] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [rmucha_a] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [rmucha_a] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'rmucha_a', N'ON'
GO
USE [rmucha_a]
GO
/****** Object:  UserDefinedFunction [dbo].[aleadsec]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[aleadsec]
(	@ID int )
returns bit
as
begin 
	return 
		case
			when @ID in (select * from workshopsWithDayReservation) then 1
			else 0
		end
end
GO
/****** Object:  UserDefinedFunction [dbo].[FindCompanyReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FindCompanyReservation] (
	@CompanyName varchar(50),
	@ConferenceName varchar(50),
	@ConferenceEditionNumber int
) returns int
as
begin 
		Declare @CompanyID as int
		select @CompanyID = CompanyID
		from Companies 
		where CompanyName = @CompanyName

		Declare @CompanyReservationID as int
		select @CompanyReservationID = CompanyReservationID
		from CompanyReservations
		inner join ConferenceEditions on CompanyReservations.ConferenceEditionID = ConferenceEditions.ConferenceEditionID
		inner join Conferences on Conferences.ConferenceID = ConferenceEditions.ConferenceID
		where CompanyID = @CompanyID and NumOfEdition = @ConferenceEditionNumber and ConferenceName = @ConferenceName


		return @CompanyReservationID
end
GO
/****** Object:  UserDefinedFunction [dbo].[GetConferenceDayID]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[GetConferenceDayID]
(
	@ConferenceName varchar(50),
	@ConferenceEditionNumber int,
	@ConferenceDayNumber int
) returns int
as 
begin
	Declare @ConferenceID as int
	select @ConferenceID = ConferenceID
	from Conferences 
	where ConferenceName = @ConferenceName

	if(@ConferenceID is null) 
	begin
		declare @errorMsg1 nvarchar(2048)
			= 'No such conference'
		;return cast(@errorMsg1 as int)
	end
	--finding ConferenceEdition
	Declare @ConferenceEditionID as int
	select @ConferenceEditionID = ConferenceEditionID
	from ConferenceEditions
	where ConferenceID = @ConferenceID and ConferenceEditions.NumOfEdition = @ConferenceEditionNumber

	if(@ConferenceEditionID is null) 
	begin
		declare @errorMsg2 nvarchar(2048)
			= 'No such conference edition'
		;return cast(@errorMsg2 as int)
	end

	--Przetestować!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	Declare @ConferenceDayID as int
	select @ConferenceDayID = b.ConferenceDayID from
	(select top 1 * from 
		(select top (@ConferenceDayNumber) * from ConferenceDays as d where d.ConferenceEditionID = @ConferenceEditionID order by d.ConferenceDayDate ) as c
		order by c.ConferenceDayDate desc
	) as b

	if(@ConferenceEditionID is null) 
	begin
		declare @errorMsg3 nvarchar(2048)
			= 'No such conference day'
		;return cast(@errorMsg3 as int)
	end
	return @ConferenceDayID;
	end;
GO
/****** Object:  UserDefinedFunction [dbo].[GetWorkshopInstanceID]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[GetWorkshopInstanceID] (
	@ConferenceDayID int,
	@StartTime time
) returns int
as 
begin 
	Declare @WorkshopInstanceID as int
	select @WorkshopInstanceID = WorkshopInstanceID
	from WorkshopInstances
	where ConferenceDayID = @ConferenceDayID and WorkshopInstances.Time = @StartTime

	if(@WorkshopInstanceID is null) 
	begin
		declare @errorMsg1 nvarchar(2048)
			= 'No such workshops'
		;return cast(@errorMsg1 as int)
	end

	return @WorkshopInstanceID
	end;
GO
/****** Object:  UserDefinedFunction [dbo].[IsConflict]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[IsConflict]
(
	@WorkshopInstanceID1 int,
	@WorkshopInstanceID2 int
)
returns int
as
begin
	return	case
		when ((select 'begin' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID1) < (select 'begin' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID2) and 
			(select 'begin' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID2) < (select 'end' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID1)) or
			 ((select 'begin' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID2) < (select 'begin' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID1) and 
			(select 'begin' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID1) < (select 'end' from WorkshopsBeginEnd as a where a.WorkshopReservationID = @WorkshopInstanceID2))
			then 1
			else 0
	end
end;
GO
/****** Object:  UserDefinedFunction [dbo].[MakesConflicts]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[MakesConflicts] (@WorkshopReservationID int)
returns bit
begin 
	return 
		case 
			when (select sum(a.Conflict) from AreConflicts as a where a.FirstWorkshopReservation = @WorkshopReservationID group by a.FirstWorkshopReservation) > 0
			then 1
			else 0
		end;
	end;
GO
/****** Object:  Table [dbo].[Addresses]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Addresses](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[CityID] [int] NOT NULL,
	[PostalCode] [char](6) NOT NULL,
	[Street] [varchar](50) NOT NULL,
	[Number] [int] NOT NULL,
 CONSTRAINT [PK_Addresses] PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cities]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cities](
	[CityID] [int] IDENTITY(1,1) NOT NULL,
	[CityName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CityNameUnique] UNIQUE NONCLUSTERED 
(
	[CityName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Companies]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Companies](
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [varchar](50) NOT NULL,
	[ContactID] [int] NOT NULL,
	[AddressID] [int] NOT NULL,
 CONSTRAINT [PK_Companies] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Companies_ContactIDUnique] UNIQUE NONCLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CompanyNameUnique] UNIQUE NONCLUSTERED 
(
	[CompanyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyConferenceDayReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyConferenceDayReservations](
	[CompanyConferenceDayReservationID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyReservationID] [int] NOT NULL,
	[Places] [int] NOT NULL,
	[ConferenceDayID] [int] NOT NULL,
 CONSTRAINT [PK_CompanyConferenceDayReservations] PRIMARY KEY CLUSTERED 
(
	[CompanyConferenceDayReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyReservations](
	[CompanyReservationID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Paid] [bit] NOT NULL,
	[ConferenceEditionID] [int] NOT NULL,
 CONSTRAINT [PK_CompanyReservations] PRIMARY KEY CLUSTERED 
(
	[CompanyReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyWorkshopInstanceReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyWorkshopInstanceReservations](
	[CompanyWorkshopInstanceReservationID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyReservationID] [int] NOT NULL,
	[WorkshopInstanceID] [int] NOT NULL,
	[Places] [int] NOT NULL,
 CONSTRAINT [PK_CompanyWorkshopInstanceReservations] PRIMARY KEY CLUSTERED 
(
	[CompanyWorkshopInstanceReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConferenceDayReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConferenceDayReservations](
	[ConferenceDayReservationID] [int] IDENTITY(1,1) NOT NULL,
	[ConferenceDayID] [int] NOT NULL,
	[ReservationID] [int] NOT NULL,
 CONSTRAINT [PK_ConferenceDayReservations] PRIMARY KEY CLUSTERED 
(
	[ConferenceDayReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConferenceDays]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConferenceDays](
	[ConferenceDayID] [int] IDENTITY(1,1) NOT NULL,
	[ConferenceEditionID] [int] NOT NULL,
	[ConferenceDayDate] [date] NOT NULL,
 CONSTRAINT [PK_ConferenceDays] PRIMARY KEY CLUSTERED 
(
	[ConferenceDayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConferenceEditions]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConferenceEditions](
	[ConferenceEditionID] [int] IDENTITY(1,1) NOT NULL,
	[ConferenceID] [int] NOT NULL,
	[NumOfEdition] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[NumOfDay] [int] NOT NULL,
	[MaxMembers] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[StudentDiscount] [float] NOT NULL,
 CONSTRAINT [PK_ConferenceEditions] PRIMARY KEY CLUSTERED 
(
	[ConferenceEditionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Conferences]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Conferences](
	[ConferenceID] [int] IDENTITY(1,1) NOT NULL,
	[ConferenceName] [varchar](50) NOT NULL,
	[ConferenceDescription] [varchar](1000) NULL,
 CONSTRAINT [PK_Conferences] PRIMARY KEY CLUSTERED 
(
	[ConferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Conferences] UNIQUE NONCLUSTERED 
(
	[ConferenceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContactDetails]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactDetails](
	[ContactID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[PhoneNumber] [numeric](9, 0) NOT NULL,
 CONSTRAINT [PK_ContactDetails] PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [EmailUnique] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [PhoneUnique] UNIQUE NONCLUSTERED 
(
	[PhoneNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeConferenceDayReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeConferenceDayReservations](
	[EmplyeeConferenceDayReservationID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyConferenceDayReservationID] [int] NOT NULL,
	[ReservationID] [int] NOT NULL,
 CONSTRAINT [PK_EmployeeConferenceDayReservations] PRIMARY KEY CLUSTERED 
(
	[EmplyeeConferenceDayReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeWorkshopInstanceReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeWorkshopInstanceReservations](
	[EmployeeWorkshopInstanceReservationID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyWorkshopInstanceReservationID] [int] NOT NULL,
	[ReservationID] [int] NOT NULL,
 CONSTRAINT [PK_EmployeeWorkshopInstanceReservations] PRIMARY KEY CLUSTERED 
(
	[EmployeeWorkshopInstanceReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PrivateReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrivateReservations](
	[PrivateReservationID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[ReservationID] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Paid] [bit] NOT NULL,
 CONSTRAINT [PK_PrivateReservations] PRIMARY KEY CLUSTERED 
(
	[PrivateReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservations](
	[ReservationID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[ConferenceEditionID] [int] NOT NULL,
 CONSTRAINT [PK_Reservations] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Students]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[UserID] [int] NOT NULL,
	[CardNumber] [int] NOT NULL,
 CONSTRAINT [PK_Students] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Students] UNIQUE NONCLUSTERED 
(
	[CardNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TimeDiscounts]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeDiscounts](
	[TimeDicountID] [int] IDENTITY(1,1) NOT NULL,
	[NumOfDaysBefore] [int] NOT NULL,
	[Discount] [float] NOT NULL,
	[ConferenceEditionID] [int] NOT NULL,
 CONSTRAINT [PK_TimeDiscount] PRIMARY KEY CLUSTERED 
(
	[TimeDicountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[ContactID] [int] NULL,
	[AddressID] [int] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Users_ContactIDUnique] UNIQUE NONCLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkshopInstances]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkshopInstances](
	[WorkshopInstanceID] [int] IDENTITY(1,1) NOT NULL,
	[WorkshopID] [int] NOT NULL,
	[ConferenceDayID] [int] NOT NULL,
	[Time] [time](7) NOT NULL,
	[MaxMembers] [int] NOT NULL,
 CONSTRAINT [PK_WorkshopInstances] PRIMARY KEY CLUSTERED 
(
	[WorkshopInstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkshopReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkshopReservations](
	[WorkshopReservationID] [int] IDENTITY(1,1) NOT NULL,
	[WorkshopInstanceID] [int] NOT NULL,
	[ReservationID] [int] NOT NULL,
 CONSTRAINT [PK_WorkshopReservations] PRIMARY KEY CLUSTERED 
(
	[WorkshopReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Workshops]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Workshops](
	[WorkshopID] [int] IDENTITY(1,1) NOT NULL,
	[WorkshopName] [varchar](50) NOT NULL,
	[WorkshopDescription] [varchar](5000) NOT NULL,
	[Mentor] [varchar](50) NOT NULL,
	[Duration] [time](7) NOT NULL,
	[Price] [money] NOT NULL,
 CONSTRAINT [PK_Workshops] PRIMARY KEY CLUSTERED 
(
	[WorkshopID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Workshops] UNIQUE NONCLUSTERED 
(
	[WorkshopName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ParticipantsInConferenceDayHelper]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ParticipantsInConferenceDayHelper] as
select p.ConferenceDayID, count(p.ConferenceDayReservationID) as Participants
from ConferenceDayReservations as p
inner join Reservations as q on p.ReservationID = q.ReservationID
inner join EmployeeConferenceDayReservations as r on r.ReservationID = q.ReservationID
inner join CompanyConferenceDayReservations as s on s.CompanyConferenceDayReservationID = r.CompanyConferenceDayReservationID
group by p.ConferenceDayID
GO
/****** Object:  View [dbo].[ParticipantsInConferenceDaysFromCompany]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ParticipantsInConferenceDaysFromCompany] as
select ConferenceDayID, sum(c.Places) as Participants from CompanyConferenceDayReservations as c
group by c.ConferenceDayID
GO
/****** Object:  View [dbo].[ParticipantsInConferenceDay]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ParticipantsInConferenceDay] as
select p.ConferenceDayID, w.Participants - s.Participants + count(p.ConferenceDayReservationID) as Participants, r.MaxMembers - count(p.ConferenceDayReservationID) + s.Participants - w.Participants as AvaliablePlaces 
from ConferenceDayReservations as p
inner join ConferenceDays as q on p.ConferenceDayID = q.ConferenceDayID
inner join ConferenceEditions as r on q.ConferenceEditionID = r.ConferenceEditionID
inner join ParticipantsInConferenceDayHelper as s on s.ConferenceDayID = p.ConferenceDayID
inner join ParticipantsInConferenceDaysFromCompany as w on w.ConferenceDayID = p.ConferenceDayID
group by p.ConferenceDayID, r.MaxMembers, s.Participants, w.Participants

GO
/****** Object:  View [dbo].[ReservationDate]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ReservationDate] as
select Reservations.ReservationID, PrivateReservations.Date from Reservations
inner join PrivateReservations on Reservations.ReservationID = PrivateReservations.ReservationID
union
select Reservations.ReservationID, CompanyReservations.Date from Reservations
inner join EmployeeConferenceDayReservations on Reservations.ReservationID = EmployeeConferenceDayReservations.ReservationID
inner join CompanyConferenceDayReservations on EmployeeConferenceDayReservations.CompanyConferenceDayReservationID = CompanyConferenceDayReservations.CompanyConferenceDayReservationID
inner join CompanyReservations on CompanyConferenceDayReservations.CompanyReservationID = CompanyReservations.CompanyReservationID
--Rezerwacji od strony Workshopow nie robię, bo jeśli są workshopy, to muszą być i dniKonferencji
GO
/****** Object:  View [dbo].[TimeDiscountHelper]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[TimeDiscountHelper] as
select Reservations.ReservationID, ConferenceEditions.Price, ConferenceEditions.Date, TimeDiscounts.NumOfDaysBefore, TimeDiscounts.Discount from Reservations
inner join ConferenceDayReservations on Reservations.ReservationID = ConferenceDayReservations.ReservationID
inner join ConferenceDays on ConferenceDayReservations.ConferenceDayID = ConferenceDays.ConferenceDayID
inner join ConferenceEditions on ConferenceDays.ConferenceEditionID = ConferenceEditions.ConferenceEditionID
inner join TimeDiscounts on ConferenceEditions.ConferenceEditionID = TimeDiscounts.ConferenceEditionID
GO
/****** Object:  View [dbo].[TimeDiscountOnReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[TimeDiscountOnReservation] as
select r.ReservationID, max(t.Discount) as 'Discount', t.Price from Reservations as r
inner join TimeDiscountHelper as t on r.ReservationID = t.ReservationID
inner join ReservationDate as d on r.ReservationID = d.ReservationID
where DATEDIFF(DAY, t.Date, d.Date) > t.NumOfDaysBefore
group by r.ReservationID, t.Price
GO
/****** Object:  View [dbo].[StudentDiscountOnReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[StudentDiscountOnReservation]  as
select a.ReservationID,
 CASE 
 when s.CardNumber is null then 0 
 else ISNULL(d.StudentDiscount, 0) end as 'Discount'
 from Reservations as a
inner join ConferenceDayReservations as b on a.ReservationID = b.ReservationID
inner join ConferenceDays as c on b.ConferenceDayID = c.ConferenceDayID
inner join ConferenceEditions as d on c.ConferenceEditionID  = d.ConferenceEditionID
left outer join Students as s on a.UserID = s.UserID
GO
/****** Object:  View [dbo].[PriceForDaysReservations]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[PriceForDaysReservations] as
select r.ReservationID, s.Discount * sum(t.Price * t.Discount) as Price from Reservations as r
inner join StudentDiscountOnReservation as s on r.ReservationID = s.ReservationID
inner join TimeDiscountOnReservation as t on r.ReservationID = t.ReservationID
group by r.ReservationID, s.Discount
GO
/****** Object:  View [dbo].[PriceForWorkshopsReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[PriceForWorkshopsReservation] as
select r.ReservationID, sum(w.Price) as Price from Reservations as r
inner join WorkshopReservations as wr on r.ReservationID = wr.ReservationID
inner join WorkshopInstances as ins on wr.WorkshopInstaceID = ins.WorkshopInstanceID
inner join Workshops as w on ins.WorkshopID = w.WorkshopID
group by r.ReservationID
GO
/****** Object:  View [dbo].[PriceForReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[PriceForReservation] as
select r.ReservationID, sum(p.Price) as Price from Reservations as r
inner join 
( select t.ReservationID, t.Price from PriceForDaysReservations as t
	union
	select w.ReservationID, w.Price from PriceForWorkshopsReservation as w ) as p
	on r.ReservationID = p.ReservationID
	group by r.ReservationID
GO
/****** Object:  View [dbo].[ParticipantsInWorkshopInstanceFromCompany]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ParticipantsInWorkshopInstanceFromCompany] as
select WorkshopInstanceID, sum(c.Places) as Participants from CompanyWorkshopInstanceReservations as c
group by c.WorkshopInstanceID
GO
/****** Object:  View [dbo].[ParticipantsInWorkshopsHelper]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ParticipantsInWorkshopsHelper] as
select p.WorkshopInstanceID, count(p.WorkshopReservationID) as Participants
from WorkshopReservations as p
inner join Reservations as q on p.ReservationID = q.ReservationID
inner join EmployeeWorkshopInstanceReservations as r on r.ReservationID = q.ReservationID
inner join CompanyWorkshopInstanceReservations as s on s.CompanyWorkshopInstanceReservationID = r.CompanyWorkshopInstanceReservationID
group by p.WorkshopInstanceID
GO
/****** Object:  View [dbo].[ParticipantsInWorkshopInstance]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ParticipantsInWorkshopInstance] as
select p.WorkshopInstanceID, s.Participants - redundant.Participants + count(p.WorkshopReservationID) as Participants, q.MaxMembers - count(p.WorkshopReservationID) + redundant.Participants - s.Participants as AvaliablePlaces from WorkshopReservations as p
inner join WorkshopInstances as q on p.WorkshopInstanceID = q.WorkshopInstanceID
inner join ParticipantsInWorkshopsHelper as redundant on p.WorkshopInstanceID = redundant.WorkshopInstanceID
inner join ParticipantsInWorkshopInstanceFromCompany as s on p.WorkshopInstanceID = s.WorkshopInstanceID
group by p.WorkshopInstanceID, q.MaxMembers, redundant.Participants, s.Participants

GO
/****** Object:  View [dbo].[AreConflicts]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[AreConflicts] as
select a.WorkshopReservationID as 'FirstWorkshopReservation', b.WorkshopReservationID as 'SecondWorkshopReservation', dbo.IsConflict(a.WorkshopReservationID, b.WorkshopReservationID) as 'Conflict'
from WorkshopReservations as a 
inner join WorkshopReservations as b on (a.ReservationID = b.ReservationID and a.WorkshopReservationID != b.WorkshopReservationID)
GO
/****** Object:  View [dbo].[ReservationsWithStudentDiscount]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ReservationsWithStudentDiscount]  as
select Reservations.ReservationID, Students.CardNumber from Reservations
inner join Students on Reservations.UserID = Students.UserID
GO
/****** Object:  View [dbo].[WorkshopsBeginEnd]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[WorkshopsBeginEnd] as
select WorkshopReservations.WorkshopReservationID, WorkshopInstances.Time as 'begin', DATEADD(MINUTE, (datepart(minute, Workshops.Duration) + 60 * DATEPART(hour, Workshops.Duration)),WorkshopInstances.Time) as 'end'
from WorkshopReservations
inner join WorkshopInstances on WorkshopReservations.WorkshopInstaceID = WorkshopInstances.WorkshopInstanceID
inner join Workshops on WorkshopInstances.WorkshopID = Workshops.WorkshopID
GO
/****** Object:  View [dbo].[workshopsWithDayReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[workshopsWithDayReservation] as
	select WorkshopReservations.WorkshopReservationID from ConferenceDayReservations
	inner join Reservations on ConferenceDayReservations.ReservationID = Reservations.ReservationID
	inner join WorkshopReservations on Reservations.ReservationID = WorkshopReservations.ReservationID
	inner join WorkshopInstances on WorkshopReservations.WorkshopInstaceID = WorkshopInstances.WorkshopInstanceID
	where WorkshopInstances.ConferenceDayID = ConferenceDayReservations.ConferenceDayID
GO
ALTER TABLE [dbo].[ConferenceEditions] ADD  CONSTRAINT [DF_ConferenceEditions_NumOfDay]  DEFAULT ((1)) FOR [NumOfDay]
GO
ALTER TABLE [dbo].[ConferenceEditions] ADD  CONSTRAINT [DF_ConferenceEditions_Price]  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[ConferenceEditions] ADD  CONSTRAINT [DF_ConferenceEditions_StudentDiscount]  DEFAULT ((0)) FOR [StudentDiscount]
GO
ALTER TABLE [dbo].[TimeDiscounts] ADD  CONSTRAINT [DF_TimeDiscount_Discount]  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [dbo].[Workshops] ADD  CONSTRAINT [DF_Workshops_Price]  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_Addresses_Cities] FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [FK_Addresses_Cities]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD  CONSTRAINT [FK_Companies_Addresses] FOREIGN KEY([AddressID])
REFERENCES [dbo].[Addresses] ([AddressID])
GO
ALTER TABLE [dbo].[Companies] CHECK CONSTRAINT [FK_Companies_Addresses]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD  CONSTRAINT [FK_Companies_ContactDetails] FOREIGN KEY([ContactID])
REFERENCES [dbo].[ContactDetails] ([ContactID])
GO
ALTER TABLE [dbo].[Companies] CHECK CONSTRAINT [FK_Companies_ContactDetails]
GO
ALTER TABLE [dbo].[CompanyConferenceDayReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyConferenceDayReservations_CompanyReservations] FOREIGN KEY([CompanyReservationID])
REFERENCES [dbo].[CompanyReservations] ([CompanyReservationID])
GO
ALTER TABLE [dbo].[CompanyConferenceDayReservations] CHECK CONSTRAINT [FK_CompanyConferenceDayReservations_CompanyReservations]
GO
ALTER TABLE [dbo].[CompanyConferenceDayReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyConferenceDayReservations_ConferenceDays] FOREIGN KEY([ConferenceDayID])
REFERENCES [dbo].[ConferenceDays] ([ConferenceDayID])
GO
ALTER TABLE [dbo].[CompanyConferenceDayReservations] CHECK CONSTRAINT [FK_CompanyConferenceDayReservations_ConferenceDays]
GO
ALTER TABLE [dbo].[CompanyReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservations_Companies] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Companies] ([CompanyID])
GO
ALTER TABLE [dbo].[CompanyReservations] CHECK CONSTRAINT [FK_CompanyReservations_Companies]
GO
ALTER TABLE [dbo].[CompanyReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservations_ConferenceEditions] FOREIGN KEY([ConferenceEditionID])
REFERENCES [dbo].[ConferenceEditions] ([ConferenceEditionID])
GO
ALTER TABLE [dbo].[CompanyReservations] CHECK CONSTRAINT [FK_CompanyReservations_ConferenceEditions]
GO
ALTER TABLE [dbo].[CompanyWorkshopInstanceReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyWorkshopInstanceReservations_CompanyReservations] FOREIGN KEY([CompanyReservationID])
REFERENCES [dbo].[CompanyReservations] ([CompanyReservationID])
GO
ALTER TABLE [dbo].[CompanyWorkshopInstanceReservations] CHECK CONSTRAINT [FK_CompanyWorkshopInstanceReservations_CompanyReservations]
GO
ALTER TABLE [dbo].[CompanyWorkshopInstanceReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyWorkshopInstanceReservations_WorkshopInstances] FOREIGN KEY([WorkshopInstanceID])
REFERENCES [dbo].[WorkshopInstances] ([WorkshopInstanceID])
GO
ALTER TABLE [dbo].[CompanyWorkshopInstanceReservations] CHECK CONSTRAINT [FK_CompanyWorkshopInstanceReservations_WorkshopInstances]
GO
ALTER TABLE [dbo].[ConferenceDayReservations]  WITH CHECK ADD  CONSTRAINT [FK_ConferenceDayReservations_ConferenceDays] FOREIGN KEY([ConferenceDayID])
REFERENCES [dbo].[ConferenceDays] ([ConferenceDayID])
GO
ALTER TABLE [dbo].[ConferenceDayReservations] CHECK CONSTRAINT [FK_ConferenceDayReservations_ConferenceDays]
GO
ALTER TABLE [dbo].[ConferenceDayReservations]  WITH CHECK ADD  CONSTRAINT [FK_ConferenceDayReservations_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[ConferenceDayReservations] CHECK CONSTRAINT [FK_ConferenceDayReservations_Reservations]
GO
ALTER TABLE [dbo].[ConferenceDays]  WITH CHECK ADD  CONSTRAINT [FK_ConferenceDays_ConferenceEditions] FOREIGN KEY([ConferenceEditionID])
REFERENCES [dbo].[ConferenceEditions] ([ConferenceEditionID])
GO
ALTER TABLE [dbo].[ConferenceDays] CHECK CONSTRAINT [FK_ConferenceDays_ConferenceEditions]
GO
ALTER TABLE [dbo].[ConferenceEditions]  WITH CHECK ADD  CONSTRAINT [FK_ConferenceEditions_Conferences] FOREIGN KEY([ConferenceID])
REFERENCES [dbo].[Conferences] ([ConferenceID])
GO
ALTER TABLE [dbo].[ConferenceEditions] CHECK CONSTRAINT [FK_ConferenceEditions_Conferences]
GO
ALTER TABLE [dbo].[EmployeeConferenceDayReservations]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeConferenceDayReservations_CompanyConferenceDayReservations] FOREIGN KEY([CompanyConferenceDayReservationID])
REFERENCES [dbo].[CompanyConferenceDayReservations] ([CompanyConferenceDayReservationID])
GO
ALTER TABLE [dbo].[EmployeeConferenceDayReservations] CHECK CONSTRAINT [FK_EmployeeConferenceDayReservations_CompanyConferenceDayReservations]
GO
ALTER TABLE [dbo].[EmployeeConferenceDayReservations]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeConferenceDayReservations_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[EmployeeConferenceDayReservations] CHECK CONSTRAINT [FK_EmployeeConferenceDayReservations_Reservations]
GO
ALTER TABLE [dbo].[EmployeeWorkshopInstanceReservations]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeWorkshopInstanceReservations_CompanyWorkshopInstanceReservations] FOREIGN KEY([CompanyWorkshopInstanceReservationID])
REFERENCES [dbo].[CompanyWorkshopInstanceReservations] ([CompanyWorkshopInstanceReservationID])
GO
ALTER TABLE [dbo].[EmployeeWorkshopInstanceReservations] CHECK CONSTRAINT [FK_EmployeeWorkshopInstanceReservations_CompanyWorkshopInstanceReservations]
GO
ALTER TABLE [dbo].[EmployeeWorkshopInstanceReservations]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeWorkshopInstanceReservations_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[EmployeeWorkshopInstanceReservations] CHECK CONSTRAINT [FK_EmployeeWorkshopInstanceReservations_Reservations]
GO
ALTER TABLE [dbo].[PrivateReservations]  WITH CHECK ADD  CONSTRAINT [FK_PrivateReservations_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[PrivateReservations] CHECK CONSTRAINT [FK_PrivateReservations_Reservations]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservations_ConferenceEditions] FOREIGN KEY([ConferenceEditionID])
REFERENCES [dbo].[ConferenceEditions] ([ConferenceEditionID])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Reservations_ConferenceEditions]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservations_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Reservations_Users]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [FK_Students_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [FK_Students_Users]
GO
ALTER TABLE [dbo].[TimeDiscounts]  WITH CHECK ADD  CONSTRAINT [FK_TimeDiscount_ConferenceEditions] FOREIGN KEY([ConferenceEditionID])
REFERENCES [dbo].[ConferenceEditions] ([ConferenceEditionID])
GO
ALTER TABLE [dbo].[TimeDiscounts] CHECK CONSTRAINT [FK_TimeDiscount_ConferenceEditions]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Addresses] FOREIGN KEY([AddressID])
REFERENCES [dbo].[Addresses] ([AddressID])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Addresses]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_ContactDetails] FOREIGN KEY([ContactID])
REFERENCES [dbo].[ContactDetails] ([ContactID])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_ContactDetails]
GO
ALTER TABLE [dbo].[WorkshopInstances]  WITH CHECK ADD  CONSTRAINT [FK_WorkshopInstances_ConferenceDays] FOREIGN KEY([ConferenceDayID])
REFERENCES [dbo].[ConferenceDays] ([ConferenceDayID])
GO
ALTER TABLE [dbo].[WorkshopInstances] CHECK CONSTRAINT [FK_WorkshopInstances_ConferenceDays]
GO
ALTER TABLE [dbo].[WorkshopInstances]  WITH CHECK ADD  CONSTRAINT [FK_WorkshopInstances_Workshops] FOREIGN KEY([WorkshopID])
REFERENCES [dbo].[Workshops] ([WorkshopID])
GO
ALTER TABLE [dbo].[WorkshopInstances] CHECK CONSTRAINT [FK_WorkshopInstances_Workshops]
GO
ALTER TABLE [dbo].[WorkshopReservations]  WITH CHECK ADD  CONSTRAINT [FK_WorkshopReservations_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[WorkshopReservations] CHECK CONSTRAINT [FK_WorkshopReservations_Reservations]
GO
ALTER TABLE [dbo].[WorkshopReservations]  WITH CHECK ADD  CONSTRAINT [FK_WorkshopReservations_WorkshopInstances] FOREIGN KEY([WorkshopInstanceID])
REFERENCES [dbo].[WorkshopInstances] ([WorkshopInstanceID])
GO
ALTER TABLE [dbo].[WorkshopReservations] CHECK CONSTRAINT [FK_WorkshopReservations_WorkshopInstances]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [correct_Number] CHECK  (([Addresses].[Number]>(0)))
GO
ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [correct_Number]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [correct_PostalCode] CHECK  (([Addresses].[PostalCode] like '[0-9][0-9]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [correct_PostalCode]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [correct_Street] CHECK  (([Addresses].[Street] like '[A-Z][a-z][a-z]%[ ]%[A-Z,a-z]%'))
GO
ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [correct_Street]
GO
ALTER TABLE [dbo].[Cities]  WITH CHECK ADD  CONSTRAINT [correct_CityName] CHECK  (([Cities].[CityName] like '[A-Z][a-z]%'))
GO
ALTER TABLE [dbo].[Cities] CHECK CONSTRAINT [correct_CityName]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD  CONSTRAINT [correct_CompanyName] CHECK  (([Companies].[CompanyName] like '[A-Z][a-z]%'))
GO
ALTER TABLE [dbo].[Companies] CHECK CONSTRAINT [correct_CompanyName]
GO
ALTER TABLE [dbo].[CompanyConferenceDayReservations]  WITH CHECK ADD  CONSTRAINT [correct_Places_CCDR] CHECK  (([CompanyConferenceDayReservations].[Places]>(0)))
GO
ALTER TABLE [dbo].[CompanyConferenceDayReservations] CHECK CONSTRAINT [correct_Places_CCDR]
GO
ALTER TABLE [dbo].[CompanyWorkshopInstanceReservations]  WITH CHECK ADD  CONSTRAINT [correct_CWIR] CHECK  (([CompanyWorkshopInstanceReservations].[Places]>(0)))
GO
ALTER TABLE [dbo].[CompanyWorkshopInstanceReservations] CHECK CONSTRAINT [correct_CWIR]
GO
ALTER TABLE [dbo].[ConferenceEditions]  WITH CHECK ADD  CONSTRAINT [correct_ConferenceEditionsMaxMembers] CHECK  (([ConferenceEditions].[MaxMembers]>(0)))
GO
ALTER TABLE [dbo].[ConferenceEditions] CHECK CONSTRAINT [correct_ConferenceEditionsMaxMembers]
GO
ALTER TABLE [dbo].[ConferenceEditions]  WITH CHECK ADD  CONSTRAINT [correct_NumOfDay] CHECK  (([ConferenceEditions].[NumOfDay]>(0)))
GO
ALTER TABLE [dbo].[ConferenceEditions] CHECK CONSTRAINT [correct_NumOfDay]
GO
ALTER TABLE [dbo].[ConferenceEditions]  WITH CHECK ADD  CONSTRAINT [correct_NumOfEdition] CHECK  (([ConferenceEditions].[NumOfEdition]>(0)))
GO
ALTER TABLE [dbo].[ConferenceEditions] CHECK CONSTRAINT [correct_NumOfEdition]
GO
ALTER TABLE [dbo].[ConferenceEditions]  WITH CHECK ADD  CONSTRAINT [correct_StudentDiscount] CHECK  (([ConferenceEditions].[StudentDiscount]>=(0) AND [ConferenceEditions].[StudentDiscount]<=(1)))
GO
ALTER TABLE [dbo].[ConferenceEditions] CHECK CONSTRAINT [correct_StudentDiscount]
GO
ALTER TABLE [dbo].[Conferences]  WITH CHECK ADD  CONSTRAINT [correct_ConferenceName] CHECK  (([Conferences].[ConferenceName] like '[A-Z][a-z]%'))
GO
ALTER TABLE [dbo].[Conferences] CHECK CONSTRAINT [correct_ConferenceName]
GO
ALTER TABLE [dbo].[ContactDetails]  WITH CHECK ADD  CONSTRAINT [correct_Email] CHECK  (([ContactDetails].[Email] like '[a-z,A-Z,_,0-9,-][a-z,A-Z,_,0-9,-]%@[a-z,0-9,_,-][a-z,0-9,_,-]%.[a-z][a-z]%'))
GO
ALTER TABLE [dbo].[ContactDetails] CHECK CONSTRAINT [correct_Email]
GO
ALTER TABLE [dbo].[ContactDetails]  WITH CHECK ADD  CONSTRAINT [correct_PhoneNumber] CHECK  (([ContactDetails].[PhoneNumber]>(99999999)))
GO
ALTER TABLE [dbo].[ContactDetails] CHECK CONSTRAINT [correct_PhoneNumber]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [correct_CardNumber] CHECK  (([Students].[CardNumber]>(0)))
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [correct_CardNumber]
GO
ALTER TABLE [dbo].[TimeDiscounts]  WITH CHECK ADD  CONSTRAINT [correct_NumOfDaysBefore] CHECK  (([TimeDiscounts].[NumOfDaysBefore]>=(0)))
GO
ALTER TABLE [dbo].[TimeDiscounts] CHECK CONSTRAINT [correct_NumOfDaysBefore]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [correct_FirstName_in_Users] CHECK  (([Users].[FirstName] like '[A-Z][a-z][a-z]%'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [correct_FirstName_in_Users]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [correct_LastName_in_Users] CHECK  (([Users].[LastName] like '[A-Z][a-z][a-z]%'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [correct_LastName_in_Users]
GO
ALTER TABLE [dbo].[WorkshopInstances]  WITH CHECK ADD  CONSTRAINT [correct_WorkshopMaxMembers] CHECK  (([WorkshopInstances].[MaxMembers]>(0)))
GO
ALTER TABLE [dbo].[WorkshopInstances] CHECK CONSTRAINT [correct_WorkshopMaxMembers]
GO
ALTER TABLE [dbo].[WorkshopReservations]  WITH CHECK ADD  CONSTRAINT [no_conflicts] CHECK  (([dbo].[MakesConflicts]([WorkshopReservationID])=(0)))
GO
ALTER TABLE [dbo].[WorkshopReservations] CHECK CONSTRAINT [no_conflicts]
GO
ALTER TABLE [dbo].[Workshops]  WITH CHECK ADD  CONSTRAINT [correct_Mentor] CHECK  (([Workshops].[Mentor] like '[A-Z][a-z]% [A-Z][a-z]%'))
GO
ALTER TABLE [dbo].[Workshops] CHECK CONSTRAINT [correct_Mentor]
GO
ALTER TABLE [dbo].[Workshops]  WITH CHECK ADD  CONSTRAINT [correct_WorkshopName] CHECK  (([Workshops].[WorkshopName] like '[A-Z][a-z]%'))
GO
ALTER TABLE [dbo].[Workshops] CHECK CONSTRAINT [correct_WorkshopName]
GO
/****** Object:  StoredProcedure [dbo].[AddAddress]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddAddress] (
	@CityName varchar(50),
	@PostalCode char(6),
	@Street varchar(50),
	@Number int
)
as
begin transaction
	set nocount on

	Declare @CityID as int
	select @CityID = CityID
	from Cities 
	where CityName = @CityName

	begin try
	--inserting Address
		insert into Addresses
		(
			CityID,
			PostalCode,
			Street,
			Number
		)
		values
		(
			@CityID,
			@PostalCode,
			@Street,
			@Number
		)
	end try
	begin catch
		rollback transaction;
		declare @errorMsg nvarchar(2048)
			= 'Cannot add Address. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddCompany]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddCompany]
	@CompanyName varchar(50),
	@Email varchar(50),
	@PhoneNumber numeric(9,0),
	@CityName varchar(50),
	@PostalCode char(6),
	@Street varchar(50),
	@Number int
as
begin transaction
--Getting CityID
	set nocount on
	--inserting Address
	begin try
		exec AddAddress @CityName, @PostalCode, @Street, @Number

		Declare @CityID as int
		select @CityID = CityID
		from Cities 
		where CityName = @CityName

		Declare @AddressID as int
		select @AddressID = AddressID
		from Addresses 
		where CityID = @CityID and @PostalCode = PostalCode and @Street = Street and @Number = Number

		--Inserting ContactDetails
		exec AddContactDetails @Email, @PhoneNumber

		Declare @ContactID as int
		select @ContactID = ContactID
		from ContactDetails 
		where Email = @Email and @PhoneNumber = PhoneNumber

		insert into Companies
		(
			CompanyName,
			ContactID,
			AddressID
		)
		values
		(
			@CompanyName,
			@ContactID,
			@AddressID
		)
	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		declare @errorMsg nvarchar(2048)
			= 'Cannot add Company. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddCompanyReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddCompanyReservation] (
	@CompanyName varchar(50),
	@ConferenceName varchar(50),
	@ConferenceEditionNumber int
) as
begin transaction

	Declare @CompanyID as int
	select @CompanyID = CompanyID
	from Companies 
	where CompanyName = @CompanyName

	Declare @ConferenceEditionID as int
	select @ConferenceEditionID = ConferenceEditionID
	from Conferences
	inner join ConferenceEditions on Conferences.ConferenceID = ConferenceEditions.ConferenceID
	where NumOfEdition = @ConferenceEditionNumber and ConferenceName = @ConferenceName

	begin try
		insert into CompanyReservations (
			CompanyID,
			Date,
			Paid,
			ConferenceEditionID
		)
		values (
			@CompanyID,
			GETDATE(),
			0,
			@ConferenceEditionID
		)
	end try
	begin catch
		rollback transaction;
		declare @errorMsg4 nvarchar(2048)
			= 'Cannot add CompanyyReservation. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg4, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddCompanyWorkshopInstanceReservation]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddCompanyWorkshopInstanceReservation]
	@CompanyName varchar(50),
	@ConferenceName varchar(50),
	@ConferenceEditionNumber int,
	@ConferenceDayNumber int,
	@WorkshopName varchar(50),
	@WorkshopStartTime time,
	@Participants int
as
begin transaction
		begin try

		--finding ConferenceDayID and WorkshopInstanceID

		Declare @ConferenceDayID as int
		Set @ConferenceDayID = dbo.GetConferenceDayID(@ConferenceName, @ConferenceEditionNumber, @ConferenceDayNumber)

		Declare @WorkshopInstanceID as int
		Set @WorkshopInstanceID = dbo.GetWorkshopInstanceID(@ConferenceDayID, @WorkshopStartTime)
	
		Declare @CompanyReservationID as int
		set @CompanyReservationID = dbo.FindCompanyReservation( @CompanyName, @ConferenceName, @ConferenceEditionNumber );
		
		if @CompanyReservationID is null
		begin
			exec AddCompanyReservation @CompanyName, @ConferenceName, @ConferenceEditionNumber

			set @CompanyReservationID = dbo.FindCompanyReservation( @CompanyName, @ConferenceName, @ConferenceEditionNumber );
		end

		--inserting CompanyWorkshopReservations
	
		insert into CompanyWorkshopInstanceReservations
		(
			CompanyReservationID,
			WorkshopInstanceID,
			Places
		)
		values
		(
			@CompanyReservationID,
			@WorkshopInstanceID,
			@Participants
		)
	end try
	begin catch
		rollback transaction;
		declare @errorMsg4 nvarchar(2048)
			= 'Cannot add WorkshopReservation. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg4, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddConference]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddConference] (
	@ConferenceName varchar(50),
	@ConferenceDescription varchar(1000),
	@Date date,
	@NumOfDays int,
	@MaxMembers int,
	@Price money,
	@StudentDiscount float
)
as
begin transaction
	set nocount on
	begin try
		insert into Conferences
		(
			ConferenceName,
			ConferenceDescription
		)
		values
		(
			@ConferenceName,
			@ConferenceDescription
		)

		exec AddConferenceEdition @ConferenceName, @Date, @NumOfDays, @MaxMembers, @Price, @StudentDiscount
	end try
	begin catch
		rollback transaction;
		declare @errorMsg nvarchar(2048)
			= 'Cannot add Conference. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddConferenceEdition]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddConferenceEdition]
	@ConferenceName varchar(50),
	@Date date,
	@NumOfDays int,
	@MaxMembers int,
	@Price money,
	@StudentDiscount float
as
begin transaction
	set nocount on
	Declare @ConferenceID as int
	select @ConferenceID = ConferenceID
	from Conferences 
	where ConferenceName = @ConferenceName

	declare @NumOfEdition as int
	select @NumOfEdition = count(ConferenceEditionID)
	from ConferenceEditions
	where ConferenceID = @ConferenceID

	set @NumOfEdition = @NumOfEdition + 1

	begin try
		insert into ConferenceEditions
		(
			ConferenceID,
			NumOfEdition,
			Date,
			NumOfDay,
			MaxMembers,
			Price,
			StudentDiscount
		)
		values
		(
			@ConferenceID,
			@NumOfEdition,
			@Date,
			@NumOfDays,
			@MaxMembers,
			@Price,
			isnull(@StudentDiscount, 0)
		)
	end try
	begin catch
		rollback transaction;
		declare @errorMsg nvarchar(2048)
			= 'Cannot add ConferenceEdition. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg, 1
	end catch
commit transaction;
GO
/****** Object:  StoredProcedure [dbo].[AddContactDetails]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddContactDetails] (
	@Email varchar(50),
	@PhoneNumber numeric(9,0)
) as
begin transaction
	set nocount on
	begin try
	insert into ContactDetails
		(
			Email,
			PhoneNumber
		)
		values
		(
			@Email,
			@PhoneNumber
		)
	end try
	begin catch
		rollback transaction;
		declare @errorMsg nvarchar(2048)
			= 'Cannot add Contact Details. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddIndividualUser]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddIndividualUser] (
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@PhoneNumber numeric(9,0),
	@CityName varchar(50),
	@PostalCode char(6),
	@Street varchar(50),
	@Number int
	) 
as
begin transaction;
--Getting CityID
	set nocount on
	
	begin try
	--inserting Address
		exec AddAddress @CityName, @PostalCode, @Street, @Number

		Declare @CityID as int
		select @CityID = CityID
		from Cities 
		where CityName = @CityName

		Declare @AddressID as int
		select @AddressID = AddressID
		from Addresses 
		where CityID = @CityID and @PostalCode = PostalCode and @Street = Street and @Number = Number

	--Inserting ContactDetails
		exec AddContactDetails @Email, @PhoneNumber

		Declare @ContactID as int
		select @ContactID = ContactID
		from ContactDetails 
		where Email = @Email and @PhoneNumber = PhoneNumber

		insert into Users
		(
			FirstName,
			LastName,
			ContactID,
			AddressID
		)
		values
		(
			@FirstName,
			@LastName,
			@ContactID,
			@AddressID
		)
	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		declare @errorMsg2 nvarchar(2048)
			= 'Cannot add Conference. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg2, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddWorkshop]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddWorkshop] (
	@WorkshopName varchar(50),
	@WorkshopDescription varchar(5000),
	@Mentor varchar(50),
	@Duration time,
	@Price money,
	@ConferenceName varchar(50),
	@ConferenceEditionNumber int,
	@ConferenceDayNumber int,
	@Time time,
	@MaxMembers money
) as
begin transaction
	begin try
		declare @ConferenceDayID as int
		set @ConferenceDayID = dbo.GetConferenceDayID(@ConferenceName, @ConferenceEditionNumber, @ConferenceDayNumber)

		insert into Workshops (
			WorkshopName,
			WorkshopDescription,
			Mentor,
			Duration,
			Price
		) values (
			@WorkshopName,
			@WorkshopDescription,
			@Mentor,
			@Duration,
			@Price
		)

		exec AddWorkshopInstance @WorkshopName, @ConferenceName, @ConferenceEditionNumber, @ConferenceDayNumber, @Time, @MaxMembers
	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		declare @errorMsg2 nvarchar(2048)
			= 'Cannot add Workshop. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg2, 1
	end catch
commit transaction
GO
/****** Object:  StoredProcedure [dbo].[AddWorkshopInstance]    Script Date: 20.01.2018 10:19:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddWorkshopInstance] (
	@WorkshopName varchar(50),
	@ConferenceName varchar(50),
	@ConferenceEditionNumber int,
	@ConferenceDayNumber int,
	@Time time,
	@MaxMembers money
) as
begin transaction
	begin try

		declare @WorkshopID as int
		select @WorkshopID = WorkshopID
		from Workshops
		where @WorkshopName = WorkshopName

		declare @ConferenceDayID as int
		set @ConferenceDayID = dbo.GetConferenceDayID(@ConferenceName, @ConferenceEditionNumber, @ConferenceDayNumber)

		insert into WorkshopInstances(
			WorkshopID,
			ConferenceDayID,
			Time,
			MaxMembers
		) values (
			@WorkshopID,
			@ConferenceDayID,
			@Time,
			@MaxMembers
		)

		end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		declare @errorMsg2 nvarchar(2048)
			= 'Cannot add Workshop instance. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg2, 1
	end catch
commit transaction
GO
USE [master]
GO
ALTER DATABASE [rmucha_a] SET  READ_WRITE 
GO
