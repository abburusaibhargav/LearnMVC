USE [master]
GO
/****** Object:  Database [TestDatabase]    Script Date: 5/21/2021 7:22:26 PM ******/
CREATE DATABASE [TestDatabase]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TestDatabase', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS01\MSSQL\DATA\TestDatabase.mdf' , SIZE = 204800KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TestDatabase_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS01\MSSQL\DATA\TestDatabase_log.ldf' , SIZE = 335872KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [TestDatabase] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TestDatabase].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TestDatabase] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TestDatabase] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TestDatabase] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TestDatabase] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TestDatabase] SET ARITHABORT OFF 
GO
ALTER DATABASE [TestDatabase] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TestDatabase] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TestDatabase] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TestDatabase] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TestDatabase] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TestDatabase] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TestDatabase] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TestDatabase] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TestDatabase] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TestDatabase] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TestDatabase] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TestDatabase] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TestDatabase] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TestDatabase] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TestDatabase] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TestDatabase] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TestDatabase] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TestDatabase] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [TestDatabase] SET  MULTI_USER 
GO
ALTER DATABASE [TestDatabase] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TestDatabase] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TestDatabase] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TestDatabase] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TestDatabase] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [TestDatabase] SET QUERY_STORE = OFF
GO
USE [TestDatabase]
GO
/****** Object:  User [super_admin]    Script Date: 5/21/2021 7:22:27 PM ******/
CREATE USER [super_admin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [super_admin]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [super_admin]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [super_admin]
GO
USE [TestDatabase]
GO
/****** Object:  Sequence [dbo].[AutoIncrement-Sequence]    Script Date: 5/21/2021 7:22:27 PM ******/
CREATE SEQUENCE [dbo].[AutoIncrement-Sequence] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE -2147483648
 MAXVALUE 2147483647
 CACHE 
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_CompoundIntEMIAmount]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Sai Bhargav Abburu
-- Create date: Dec 05, 2020
-- Description:	Returns Compound Interest for EMI Amount
-- Formula-> Compound Interest = I*(POWER((1+(Interest/100)),Tenure))
-- =============================================
CREATE FUNCTION [dbo].[UDF_CompoundIntEMIAmount]
(
@principleamount decimal(16,2),
@interest int,
@tenure decimal(16,2)
)
RETURNS DECIMAL(16,2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @emiamount decimal(16,2)
	DECLARE @interestpm decimal(16,2)

	SELECT @emiamount = @principleamount*(POWER((1+(@interest/100)),@tenure))

	-- Return the result of the function
	RETURN @emiamount

END
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_SimpleIntEMIAmount]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author: Sai Bhargav Abburu
-- Create date: Dec 05, 2020
-- Description:	Returns Simple Interest EMI Amount
---------------------------------------------------------------------
--EMI Calculation
-->-->EMI = [P x R x (1 + R)^N] / [(1 + R)^N - 1]<--<--
--
--SELECT ROUND((Principle*((Interest/100)/Tenure in months)*POWER(1+((Interest/100)/Tenure in months),Tenure in months))
--/
--(POWER(1+((Interest/100)/Tenure in months),Tenure in months)-1),3)
--SELECT ROUND((100000*((20.00/100)/12)*POWER(1+((20.00/100)/12),12))/(POWER(1+((20.00/100)/12),12)-1),3)
---------------------------------------------------------------------
--EXECUTE FUNCTION
--SELECT [dbo].[UDF_SimpleIntEMIAmount] ('Y',151010,14.95,1)
-- =============================================
CREATE FUNCTION [dbo].[UDF_SimpleIntEMIAmount](
@loantype nvarchar(2),
@principleamount decimal(16,2),
@interest decimal(16,2),
@tenure int
)
RETURNS DECIMAL(16,2)
AS
BEGIN
	declare @emiamount decimal(16,2)
	declare @interestpm decimal(16,2)

	IF(@loantype='Y')
	BEGIN
		SET @emiamount = (@principleamount*@tenure*@interest)/100
		SET @interestpm = CEILING(@emiamount/(@tenure*12))
	END
	
	IF(@loantype='M')
	BEGIN
		SET @emiamount = (@principleamount*@tenure*@interest)/100
		SET @interestpm = CEILING(@emiamount/(@tenure))
	END
	
	
--SELECT @emiamount=
--ROUND((@principleamount*((@interest/100)/@tenure)*POWER(1+((@interest/100)/@tenure),@tenure))
--/ -->Divide By
--(POWER(1+((@interest/100)/@tenure),@tenure)-1),2)
--SELECT ROUND((100000*((20.00/100)/12)*POWER(1+((20.00/100)/12),12))/(POWER(1+((20.00/100)/12),12)-1),2)

	RETURN @interestpm

END
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ConvertTimePerTimeZone]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abburu Sai Bhargav
-- Create date: 
-- Description:	Convert time as per timezone
-- =============================================
CREATE FUNCTION [dbo].[ufn_ConvertTimePerTimeZone] 
(
	@timezone nvarchar(100)
)
RETURNS datetime
AS
BEGIN
	Declare @ReturnTime datetime
	Declare @adjhrs int
	Declare @adjmin int
	Declare @ConvertedTime datetime
	Declare @utctime datetime

	SET @utctime = GETUTCDATE()
	SELECT @adjhrs = LEFT(RIGHT(@timezone,5),2)
	SELECT @adjmin = RIGHT(@timezone,2)

	IF((SELECT CHARINDEX('+',@timezone)) > 0)
	BEGIN
		SELECT @adjmin = @adjmin+(@adjhrs*60)
	END
	ELSE
	BEGIN
		SELECT @adjmin = @adjmin-(@adjhrs*60)
	END

	SELECT @ConvertedTime = DATEADD(MINUTE,@adjmin,@utctime)

	SELECT @ReturnTime = @ConvertedTime

	RETURN @ReturnTime

END
GO
/****** Object:  Table [dbo].[Announcements]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Announcements](
	[AnnouncementID] [nvarchar](100) NOT NULL,
	[AnnouncementTitle] [nvarchar](500) NULL,
	[AnnouncementContent] [nvarchar](max) NULL,
	[Active] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[AnnouncementClassification] [nvarchar](20) NULL,
 CONSTRAINT [PK_Announcements] PRIMARY KEY CLUSTERED 
(
	[AnnouncementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ASCII_Reference]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ASCII_Reference](
	[ASCII_Ref_ID] [nvarchar](50) NOT NULL,
	[ASCII_Code] [int] NULL,
	[Unicode_Code] [int] NULL,
	[Ref_Char] [nvarchar](2) NULL,
	[Ref_Int] [int] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifedBy] [nvarchar](50) NULL,
	[ModifedDate] [datetime] NULL,
 CONSTRAINT [PK_ASCII_Reference] PRIMARY KEY CLUSTERED 
(
	[ASCII_Ref_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AutoGeneratedAudit]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoGeneratedAudit](
	[AGDID] [nvarchar](50) NOT NULL,
	[AutoGenRefID] [nvarchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[GeneratedBy] [nvarchar](50) NULL,
	[GeneratedDate] [datetime] NULL,
	[AutoGenType] [nvarchar](50) NULL,
	[ProcessedRecords] [int] NULL,
	[DeleteDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_AGDID] PRIMARY KEY CLUSTERED 
(
	[AGDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AutoGeneratedDates]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoGeneratedDates](
	[DateID] [nvarchar](50) NOT NULL,
	[Date] [int] NULL,
	[Month] [nvarchar](50) NULL,
	[Year] [nvarchar](50) NULL,
	[Day] [nvarchar](50) NULL,
	[FullDate] [datetime] NULL,
	[WeekNo] [int] NULL,
	[Active] [bit] NULL,
	[GeneratedBy] [nvarchar](50) NULL,
	[GeneratedDate] [datetime] NULL,
	[AuditRefID] [nvarchar](50) NULL,
	[PublicHoliday] [bit] NULL,
	[Weekend] [bit] NULL,
	[SalaryProcessing] [bit] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_DateID] PRIMARY KEY CLUSTERED 
(
	[DateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AutoGeneratedNames]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoGeneratedNames](
	[RegNo] [nvarchar](50) NOT NULL,
	[first_name] [nvarchar](50) NULL,
	[last_name] [nvarchar](50) NULL,
	[gender] [nvarchar](10) NULL,
	[email] [nvarchar](100) NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[AuditRefID] [nvarchar](50) NULL,
	[Phone] [nvarchar](50) NULL,
	[Login_Cred_Ref_Num] [nvarchar](50) NULL,
 CONSTRAINT [PK_AutoGeneratedNames] PRIMARY KEY CLUSTERED 
(
	[RegNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [dbo].[AutoGeneratedNames].[first_name] WITH (label = 'Confidential - GDPR', label_id = '989adc05-3f3f-0588-a635-f475b994915b', information_type = 'Name', information_type_id = '57845286-7598-22f5-9659-15b24aeb125e');
GO
ADD SENSITIVITY CLASSIFICATION TO [dbo].[AutoGeneratedNames].[last_name] WITH (label = 'Confidential - GDPR', label_id = '989adc05-3f3f-0588-a635-f475b994915b', information_type = 'Name', information_type_id = '57845286-7598-22f5-9659-15b24aeb125e');
GO
ADD SENSITIVITY CLASSIFICATION TO [dbo].[AutoGeneratedNames].[email] WITH (label = 'Confidential', label_id = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1');
GO
ADD SENSITIVITY CLASSIFICATION TO [dbo].[AutoGeneratedNames].[Phone] WITH (label = 'Confidential', label_id = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1');
GO
/****** Object:  Table [dbo].[ConsigneeDetails]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsigneeDetails](
	[ConsigneeDetailsID] [nvarchar](100) NOT NULL,
	[BookingID] [nvarchar](100) NOT NULL,
	[ConsigneeName] [nvarchar](100) NOT NULL,
	[ConsignerName] [nvarchar](100) NOT NULL,
	[Active] [nvarchar](100) NOT NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ConsigneeDetails] PRIMARY KEY CLUSTERED 
(
	[ConsigneeDetailsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConsignmentDetails]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsignmentDetails](
	[ConsignmentBookingRefID] [nvarchar](100) NOT NULL,
	[BookingID] [nvarchar](100) NOT NULL,
	[BookingOfficeID] [nvarchar](100) NOT NULL,
	[DestinationOfficeID] [nvarchar](100) NOT NULL,
	[DestinationPincode] [int] NOT NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[ConsignmentStatusID] [nvarchar](100) NULL,
	[StatusDate] [datetime] NULL,
	[DestinationAddress] [nvarchar](500) NULL,
 CONSTRAINT [PK_ConsignmentDetails] PRIMARY KEY CLUSTERED 
(
	[BookingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConsignmentStatus]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsignmentStatus](
	[ConsignmentStatusID] [nvarchar](100) NOT NULL,
	[ConsignmentStatusName] [nvarchar](100) NOT NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_ConsignmentStatus] PRIMARY KEY CLUSTERED 
(
	[ConsignmentStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Covid_Data]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Covid_Data](
	[Date] [date] NULL,
	[CurrentMatch] [date] NULL,
	[Value] [bigint] NULL,
	[Cumulative] [bigint] NULL,
	[YEAR] [int] NULL,
	[IsWeekday] [bit] NULL,
	[Day] [nvarchar](20) NULL,
	[CurrencyValue] [nvarchar](5) NULL,
	[Direction] [varchar](15) NULL,
	[ID] [nvarchar](50) NULL
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [dbo].[Covid_Data].[CurrencyValue] WITH (label = 'Confidential', label_id = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373');
GO
/****** Object:  Table [dbo].[Covid_TestData]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Covid_TestData](
	[Direction] [nvarchar](50) NOT NULL,
	[Year] [smallint] NOT NULL,
	[Date] [date] NOT NULL,
	[Weekday] [nvarchar](50) NOT NULL,
	[Current_Match] [date] NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[Commodity] [nvarchar](50) NOT NULL,
	[Transport_Mode] [nvarchar](50) NOT NULL,
	[Measure] [nvarchar](50) NOT NULL,
	[Value] [int] NOT NULL,
	[Cumulative] [float] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DashboardData]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DashboardData](
	[loginuserrole] [nvarchar](100) NULL,
	[TotalConsignmentTillDate] [int] NULL,
	[TotalOffices] [int] NULL,
	[TotalDeliveryOffices] [int] NULL,
	[TotalnonDeliveryOffices] [int] NULL,
	[TotalBranchOffices] [int] NULL,
	[TotalSubBranchOffices] [int] NULL,
	[TotalHeadOffices] [int] NULL,
	[AnnualTurnOver] [nvarchar](100) NULL,
	[MaintainenceCost] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Data_Process_Log]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Data_Process_Log](
	[DataProcessTranID] [nvarchar](100) NOT NULL,
	[ServerTransactionID] [nvarchar](100) NOT NULL,
	[UploadTransactionID] [nvarchar](100) NULL,
	[UploadFileName] [nvarchar](100) NULL,
	[ProcessStart] [datetime] NULL,
	[ProcessEnd] [datetime] NULL,
	[ProcessStatus] [nvarchar](50) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_DataProcessLog] PRIMARY KEY CLUSTERED 
(
	[DataProcessTranID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmiTable]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmiTable](
	[EmiRefID] [nvarchar](50) NOT NULL,
	[LoanRefID] [nvarchar](100) NOT NULL,
	[LoanID] [nvarchar](50) NULL,
	[Month] [nvarchar](20) NULL,
	[CycleDate] [datetime] NULL,
	[RepaymentDate] [datetime] NULL,
	[PrincipleAmount] [int] NULL,
	[InterestAmount] [int] NULL,
	[TotalPayable] [int] NULL,
	[Paid] [bit] NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreateadDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LandingImages]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LandingImages](
	[LandingImageID] [nvarchar](100) NOT NULL,
	[LandingImageName] [nvarchar](100) NULL,
	[LandingImagePath] [nvarchar](100) NOT NULL,
	[SortOrder] [int] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime] NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_LandingImages] PRIMARY KEY CLUSTERED 
(
	[LandingImageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LoanDetails]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanDetails](
	[LoanRefID] [nvarchar](100) NOT NULL,
	[UserID] [nvarchar](50) NOT NULL,
	[LoanID] [nvarchar](100) NOT NULL,
	[PrincipleAmount] [decimal](16, 2) NULL,
	[Type] [nvarchar](50) NULL,
	[Interest] [decimal](10, 3) NULL,
	[Tenure] [int] NULL,
	[Active] [bit] NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[InterestPercent] [decimal](16, 2) NULL,
	[ApprovedDate] [datetime] NULL,
	[BalancePayable] [decimal](16, 2) NULL,
	[BalPrinciple] [decimal](16, 2) NULL,
	[BalInterest] [decimal](16, 2) NULL,
	[ProcessingAmt] [decimal](16, 2) NULL,
 CONSTRAINT [PK_LoanDetails] PRIMARY KEY CLUSTERED 
(
	[LoanRefID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Login_Credentials]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Login_Credentials](
	[Credentials_Ref_ID] [nvarchar](50) NOT NULL,
	[LoginID] [nvarchar](20) NULL,
	[Password] [nvarchar](12) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Login_Credentials] PRIMARY KEY CLUSTERED 
(
	[Credentials_Ref_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Menu]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menu](
	[MenuID] [nvarchar](100) NOT NULL,
	[MenuName] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[Controller] [nvarchar](100) NOT NULL,
	[ActionMethod] [nvarchar](100) NOT NULL,
	[SortOrder] [int] NULL,
	[Active] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
 CONSTRAINT [PK_MainMenu] PRIMARY KEY CLUSTERED 
(
	[MenuID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Messages]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Messages](
	[MessageID] [nvarchar](100) NOT NULL,
	[SenderID] [nvarchar](100) NOT NULL,
	[ReceiverID] [nvarchar](100) NOT NULL,
	[MessageSubject] [nvarchar](100) NULL,
	[Message] [nvarchar](100) NULL,
	[ReplyRequired] [bit] NULL,
	[Acknowledged] [bit] NULL,
	[MessageParentID] [nvarchar](100) NULL,
	[ReplyMessage] [nvarchar](100) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [nvarchar](100) NULL,
	[Active] [bit] NULL,
	[ReplyDate] [datetime] NULL,
 CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NumToWords]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NumToWords](
	[NumToWordsID] [int] IDENTITY(1,1) NOT NULL,
	[IntValue] [int] NULL,
	[WordValue] [nvarchar](50) NULL,
	[Placeterm] [nvarchar](50) NULL,
	[PlaceIntstart] [int] NULL,
	[Active] [bit] NULL,
	[CallbyTerm] [nvarchar](20) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[NumToWordsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Circle_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Circle_List](
	[CircleID] [nvarchar](100) NOT NULL,
	[StateID] [nvarchar](100) NOT NULL,
	[CircleName] [nvarchar](100) NOT NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](20) NULL,
	[ModifiedDate] [datetime] NULL,
	[AuditRefID] [nvarchar](100) NULL,
 CONSTRAINT [PK_Postal_Circle_List] PRIMARY KEY CLUSTERED 
(
	[CircleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Data_Staging]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Data_Staging](
	[State] [nvarchar](100) NULL,
	[CircleName] [nvarchar](100) NULL,
	[RegionName] [nvarchar](100) NULL,
	[DivisionName] [nvarchar](100) NULL,
	[District] [nvarchar](100) NULL,
	[OfficeName] [nvarchar](100) NULL,
	[OfficeType] [nvarchar](5) NULL,
	[Delivery] [nvarchar](20) NULL,
	[Pincode] [int] NULL,
	[StageTransactionID] [nvarchar](100) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Delivery_Type]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Delivery_Type](
	[DeliveryID] [nvarchar](100) NOT NULL,
	[DeliveryType] [nvarchar](50) NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_Delivery_Type] PRIMARY KEY CLUSTERED 
(
	[DeliveryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_District_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_District_List](
	[DistrictID] [nvarchar](100) NOT NULL,
	[DivisionID] [nvarchar](100) NULL,
	[DistrictName] [nvarchar](100) NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_District_List] PRIMARY KEY CLUSTERED 
(
	[DistrictID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Division_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Division_List](
	[DivisionID] [nvarchar](100) NOT NULL,
	[RegionID] [nvarchar](100) NOT NULL,
	[DivisionName] [nvarchar](50) NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_Division_List] PRIMARY KEY CLUSTERED 
(
	[DivisionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Office_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Office_List](
	[OfficeID] [nvarchar](100) NOT NULL,
	[DistrictID] [nvarchar](100) NOT NULL,
	[OfficeName] [nvarchar](100) NULL,
	[OfficeTypeID] [nvarchar](100) NULL,
	[DeliveryTypeID] [nvarchar](100) NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_Office_List] PRIMARY KEY CLUSTERED 
(
	[OfficeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Office_Type]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Office_Type](
	[OfficeTypeID] [nvarchar](100) NOT NULL,
	[OfficeTypeCode] [nvarchar](5) NOT NULL,
	[OfficeTypeName] [nvarchar](100) NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_Office_Type] PRIMARY KEY CLUSTERED 
(
	[OfficeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Pincode_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Pincode_List](
	[PincodeID] [nvarchar](100) NOT NULL,
	[OfficeID] [nvarchar](100) NOT NULL,
	[Pincode] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_Pincode_List] PRIMARY KEY CLUSTERED 
(
	[PincodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_Region_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_Region_List](
	[RegionID] [nvarchar](100) NOT NULL,
	[CircleID] [nvarchar](100) NOT NULL,
	[RegionName] [nvarchar](100) NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_Region_List] PRIMARY KEY CLUSTERED 
(
	[RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postal_State_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postal_State_List](
	[StateID] [nvarchar](100) NOT NULL,
	[StateName] [nvarchar](50) NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Postal_State_List] PRIMARY KEY CLUSTERED 
(
	[StateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubMenu]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubMenu](
	[SubMenuID] [nvarchar](100) NOT NULL,
	[MenuID] [nvarchar](100) NOT NULL,
	[SubMenuName] [nvarchar](100) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[Active] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TimeZone]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeZone](
	[TimezoneID] [nvarchar](100) NOT NULL,
	[Country] [nvarchar](100) NULL,
	[Timezone] [nvarchar](100) NULL,
	[AdjustHours] [int] NULL,
	[AdjustMinutes] [int] NULL,
	[CountryTime] [datetime] NULL,
	[Sortorder] [int] NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime] NULL,
	[Highlight] [bit] NULL,
 CONSTRAINT [PK_TimeZone] PRIMARY KEY CLUSTERED 
(
	[TimezoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrackConsignment]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrackConsignment](
	[TrackConsignmentID] [nvarchar](100) NOT NULL,
	[BookingID] [nvarchar](100) NOT NULL,
	[ConsignmentStatusID] [nvarchar](100) NOT NULL,
	[StatusDateTime] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[Active] [bit] NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_TrackConsignment] PRIMARY KEY CLUSTERED 
(
	[TrackConsignmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionSummary]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionSummary](
	[TranSumryID] [nvarchar](50) NOT NULL,
	[AuditRefID] [nvarchar](50) NULL,
	[ActionOn] [nvarchar](200) NULL,
	[Action] [nvarchar](200) NULL,
	[ActionStatus] [nvarchar](200) NULL,
	[GeneratedBy] [nvarchar](50) NULL,
	[GeneratedDate] [datetime] NULL,
 CONSTRAINT [PK_TransactionSummary] PRIMARY KEY CLUSTERED 
(
	[TranSumryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Transummary]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transummary](
	[Tranname] [nvarchar](100) NULL,
	[TranCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UploadTransactionLog]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UploadTransactionLog](
	[UploadTransactionID] [nvarchar](100) NOT NULL,
	[UploadFileName] [nvarchar](500) NULL,
	[UploadFileServerPath] [nvarchar](max) NULL,
	[UploadFileDescription] [nvarchar](max) NULL,
	[UploadedBy] [nvarchar](50) NULL,
	[UploadedOn] [datetime] NULL,
	[ServerTransactionID] [nvarchar](100) NULL,
 CONSTRAINT [PK_UploadTransactionLog] PRIMARY KEY CLUSTERED 
(
	[UploadTransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UploadTranSummary]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UploadTranSummary](
	[SummaryRefID] [nvarchar](100) NOT NULL,
	[StageTranID] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[CountOfChanges] [int] NULL,
	[Uploadedby] [nvarchar](100) NULL,
	[UploadedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SummaryRefID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [nvarchar](50) NOT NULL,
	[first_name] [nvarchar](50) NULL,
	[last_name] [nvarchar](50) NULL,
	[gender] [nvarchar](10) NULL,
	[email] [nvarchar](100) NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[AuditRefID] [nvarchar](50) NULL,
	[Phone] [nvarchar](50) NULL,
	[Username] [nvarchar](50) NULL,
	[Credentails_Ref_Id] [nvarchar](100) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[password] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
 CONSTRAINT [PK_UserID] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsigneeDetails]  WITH CHECK ADD  CONSTRAINT [FK_Consignee_BookingID_Consignment_BookingID] FOREIGN KEY([BookingID])
REFERENCES [dbo].[ConsignmentDetails] ([BookingID])
GO
ALTER TABLE [dbo].[ConsigneeDetails] CHECK CONSTRAINT [FK_Consignee_BookingID_Consignment_BookingID]
GO
ALTER TABLE [dbo].[EmiTable]  WITH CHECK ADD  CONSTRAINT [FK_Emi_LoanDetails] FOREIGN KEY([LoanRefID])
REFERENCES [dbo].[LoanDetails] ([LoanRefID])
GO
ALTER TABLE [dbo].[EmiTable] CHECK CONSTRAINT [FK_Emi_LoanDetails]
GO
ALTER TABLE [dbo].[LoanDetails]  WITH CHECK ADD  CONSTRAINT [FK_LoanDetails_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[LoanDetails] CHECK CONSTRAINT [FK_LoanDetails_Users]
GO
ALTER TABLE [dbo].[Postal_Circle_List]  WITH CHECK ADD  CONSTRAINT [FK_CID_SID] FOREIGN KEY([StateID])
REFERENCES [dbo].[Postal_State_List] ([StateID])
GO
ALTER TABLE [dbo].[Postal_Circle_List] CHECK CONSTRAINT [FK_CID_SID]
GO
ALTER TABLE [dbo].[Postal_District_List]  WITH CHECK ADD  CONSTRAINT [FK_DID_DVID] FOREIGN KEY([DivisionID])
REFERENCES [dbo].[Postal_Division_List] ([DivisionID])
GO
ALTER TABLE [dbo].[Postal_District_List] CHECK CONSTRAINT [FK_DID_DVID]
GO
ALTER TABLE [dbo].[Postal_Division_List]  WITH CHECK ADD  CONSTRAINT [FK_DvID_RID] FOREIGN KEY([RegionID])
REFERENCES [dbo].[Postal_Region_List] ([RegionID])
GO
ALTER TABLE [dbo].[Postal_Division_List] CHECK CONSTRAINT [FK_DvID_RID]
GO
ALTER TABLE [dbo].[Postal_Office_List]  WITH CHECK ADD  CONSTRAINT [FK_OID_DID] FOREIGN KEY([DistrictID])
REFERENCES [dbo].[Postal_District_List] ([DistrictID])
GO
ALTER TABLE [dbo].[Postal_Office_List] CHECK CONSTRAINT [FK_OID_DID]
GO
ALTER TABLE [dbo].[Postal_Pincode_List]  WITH CHECK ADD  CONSTRAINT [FK_PID_OID] FOREIGN KEY([OfficeID])
REFERENCES [dbo].[Postal_Office_List] ([OfficeID])
GO
ALTER TABLE [dbo].[Postal_Pincode_List] CHECK CONSTRAINT [FK_PID_OID]
GO
ALTER TABLE [dbo].[Postal_Region_List]  WITH CHECK ADD  CONSTRAINT [FK_RID_CID] FOREIGN KEY([CircleID])
REFERENCES [dbo].[Postal_Circle_List] ([CircleID])
GO
ALTER TABLE [dbo].[Postal_Region_List] CHECK CONSTRAINT [FK_RID_CID]
GO
ALTER TABLE [dbo].[TransactionSummary]  WITH CHECK ADD  CONSTRAINT [FK_TransactionSummary_TransactionSummary] FOREIGN KEY([TranSumryID])
REFERENCES [dbo].[TransactionSummary] ([TranSumryID])
GO
ALTER TABLE [dbo].[TransactionSummary] CHECK CONSTRAINT [FK_TransactionSummary_TransactionSummary]
GO
/****** Object:  StoredProcedure [dbo].[ApproveLoan]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Sai Bhargav Abbuuru
-- Create date: Nov 30, 2020
-- Description:	Approve Loan
--
--EXEC ApproveLoan 'AVSSB-LOAN-20201130-C152D'
-- =============================================
CREATE PROCEDURE [dbo].[ApproveLoan] @LoanID nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(Select 1 from LoanDetails where LoanID=@LoanID and [Status]<>'Approved')
	BEGIN
		EXEC [dbo].[RecordTranSummary] @LoanID,'[dbo].[LoanDetails]','Loan Generated','Approved'

		Update LoanDetails SET [Status]='Approved',Active=1,ModifiedBy='SYSTEM',ModifiedDate=GETDATE(),ApprovedDate=GETDATE() where LoanID=@LoanID
	END
END
GO
/****** Object:  StoredProcedure [dbo].[AutoGenerateDates]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--================================================================================================
-- Author:		Sai Bhargav Abburu
-- Create date: Nov 24, 2020
-- Description: Functions that SP does -
			  /*1.Autogenerate dates between given range(Years/Months/Weeks/Days).
				2.Assign Public Holidays
				3.Assign Weekends
				4.Assign Salary Processing Dates.
				5.Generates Execution Summary.
				6. Sends mail to the requestor with autogenerated dates and attachment 
				   along with Execution Summary.*/
--================================================================================================
-- EXEC [dbo].[AutoGenerateDates] 1,1,year,'ibhargav547@gmail.com',1,'2020-10-01','2021-10-15' -->Manual Execution

----@type = 1-->Forward | 0--> Backward ----DEFAULT IS 'Forward'
----@increment_type = 'Year'| 'Month' | 'Day' -----DEFAULT IS 'Year'
----email - Email is mandatory
--================================================================================================
CREATE PROCEDURE [dbo].[AutoGenerateDates] @targetyear int,@type int, @increment_type nvarchar(50),@email nvarchar(100),@range_type bit,@date_from date,@date_to date
AS
BEGIN  --> SP Start
	BEGIN-->Dates creation - Begin
		declare @enddate int
		declare @maxdate datetime
		declare @startdate datetime
		declare @counter int
		declare @maxcounter int
		declare @auditrecordid nvarchar(50)
		declare @AutoGenID nvarchar(50) = CONCAT('AVSSB-AUDIT-',RIGHT(NEWID(),5))
		declare @typename nvarchar(20)
		declare @exec_start datetime = GETDATE()
		declare @exec_end datetime
		declare @transtat nvarchar(50)
		declare @tranauditnum nvarchar(50)
		declare @tranrefnum nvarchar(50)
		declare @incr_type nvarchar(50)
		declare @weekendcounter nvarchar(20)
		declare @pubholidaycounter nvarchar(20)
		declare @salcounter nvarchar(50)

		set @startdate = CAST(getdate()as DATE)

		IF(@range_type=1)
			BEGIN
				SET @typename='Range'
				EXEC [dbo].[RecordTranSummary] @AutoGenID,'[dbo].[AutoGenerateDates]','Auto Generate Dates Start - Range','Started'

				IF EXISTS (select 1 from AutoGeneratedDates)
				BEGIN
					SELECT @auditrecordid = [AuditRefID] from AutoGeneratedDates
					Update [dbo].[AutoGeneratedAudit] set DeleteDate = GETDATE(),ModifiedBy='SYSTEM',ModifiedDate=GETDATE()
					where [AGDID] =@auditrecordid

					TRUNCATE TABLE AutoGeneratedDates
					TRUNCATE TABLE TranSummary
				END

				IF(LOWER(@increment_type)='year')
				BEGIN
					IF(@type=1)
					BEGIN
						SET @date_from = GETDATE();
						SET @date_to = DATEADD(YYYY,@targetyear,GETDATE())
					END
					IF(@type=0)
					BEGIN
						SET @date_to = GETDATE();
						SET @date_from = DATEADD(YYYY,-@targetyear,GETDATE())
					END	
				END

				IF(LOWER(@increment_type)='month')
				BEGIN
					IF(@type=1)
					BEGIN
						SET @date_from = GETDATE();
						SET @date_to = DATEADD(MM,@targetyear,GETDATE())
					END
					IF(@type=0)
					BEGIN
						SET @date_to = GETDATE();
						SET @date_from = DATEADD(MM,-@targetyear,GETDATE())
					END	
				END

				IF(LOWER(@increment_type)='days')
				BEGIN
					IF(@type=1)
					BEGIN
						SET @date_from = GETDATE();
						SET @date_to = DATEADD(DD,@targetyear,GETDATE())
					END
					IF(@type=0)
					BEGIN
						SET @date_to = GETDATE();
						SET @date_from = DATEADD(DD,-@targetyear,GETDATE())
					END	
				END
				

				declare	@return_value int
				--> Stored Procedure to generate dates between given range.(Nested Stored Proc.)
				EXEC @return_value = [dbo].[GenerateDatesBetweenRange] @date_from,@date_to,@AutoGenID

				BEGIN 
				--> Nested Stored Proc. to update public,weekend holidays ans salary processing dates.
					EXEC [dbo].[UpdatePubWeekSalProcRecords] @AutoGenID

					Select @pubholidaycounter = COUNT(1) from [dbo].[AutoGeneratedDates] where PublicHoliday=1
					Select @salcounter = COUNT(1) from [dbo].[AutoGeneratedDates]where SalaryProcessing=1
					SELECT @weekendcounter=COUNT(1) from [dbo].[AutoGeneratedDates] where Weekend=1
							
					Insert into Transummary values (CONCAT('Total Salary Dates from - ',@date_from,' - ',@date_to),CONVERT(NVARCHAR(50),@salcounter))
					Insert into Transummary values (CONCAT('Total Public Holiday from - ',@date_from,' - ',@date_to),CONVERT(NVARCHAR(50),@pubholidaycounter))
					Insert into Transummary values (CONCAT('Total Weekend Holidays from - ',@date_from,' - ',@date_to),CONVERT(NVARCHAR(50),@weekendcounter))
				END
				
				IF(@return_value=0)
				BEGIN
					SET @transtat = 'Committed and Successful'
					SET @exec_end = GETDATE()

					Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[StartDate],[EndDate],[ProcessedRecords],[GeneratedBy],[GeneratedDate],[AutoGenType])
					Values
					(@AutoGenID,CONCAT('AVSSB-AGD-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'-SUCCESS-',RIGHT(NEWID(),3)),
					@date_from,@date_to,CONVERT(int,@counter),'SYSTEM',GETDATE(),CONCAT('Auto-Generated Dates-','-','Range'))
					
					SELECT @tranrefnum = [AutoGenRefID] from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AutoGenID 

					EXEC [dbo].[RecordTranSummary] @AutoGenID,'[dbo].[AutoGenerateDates]','Auto Generate Dates End - Range','Completed'

				END
				ELSE
				BEGIN
					SET @transtat = 'Rolledback and failed'
					SET @exec_end = GETDATE()

					Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[StartDate],[EndDate],[ProcessedRecords],[GeneratedBy],[GeneratedDate],[AutoGenType])
					Values
					(@AutoGenID,CONCAT('AVSSB-AGD-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'-FAILED-',RIGHT(NEWID(),3)),
					@date_from,@date_to,CONVERT(int,@counter),'SYSTEM',GETDATE(),CONCAT('Auto-Generated Dates-','-','Range'))

					SELECT @tranrefnum = [AutoGenRefID] from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AutoGenID 
					EXEC [dbo].[RecordTranSummary] @AutoGenID,'[dbo].[AutoGenerateDates]','Auto Generate Dates End - Range','Failed'

					INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
					VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates Range - Generate','Error','SYSTEM',GETDATE())
				END
				SET @exec_end = GETDATE()
			END
		ELSE
			BEGIN
				IF(ISNULL(@type,1)=1) -->. Forward Dates
					INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
					VALUES
					(NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates Start - Forward','Started','SYSTEM',GETDATE())

					BEGIN
						IF(ISNULL(@increment_type,'')='' or LOWER(@increment_type)='year')
							BEGIN
								set @maxdate = CAST(DATEADD(YYYY,@targetyear,@startdate)as DATE)
								IF(ISNULL(@increment_type,'')='')
									BEGIN
										SET @incr_type='Default Mode(Yearly)'
									END
								ELSE
									BEGIN
										set @incr_type='Yearly'
									END		
							END
						IF(LOWER(@increment_type)='month')
							BEGIN
								set @maxdate = CAST(DATEADD(MM,@targetyear,@startdate)as DATE)
								set @incr_type='Monthly'
							END
						IF(LOWER(@increment_type)='day')
							BEGIN
								set @maxdate = CAST(DATEADD(DD,@targetyear,@startdate)as DATE)
								set @incr_type='Days'
							END

						set @maxcounter = DATEDIFF(dd,@startdate,@maxdate)

						IF(ISNULL(@type,'')='')
							BEGIN
								set @typename='Default Type(Forward)'
							END
							ELSE
							BEGIN
								set @typename='Forward'
							END
				
					END
				IF(@type=0) --> Backward Dates
					BEGIN
						--set @targetyear = CONVERT(NVARCHAR(50),-@targetyear)
						EXEC [dbo].[RecordTranSummary] @AutoGenID,'[dbo].[AutoGenerateDates]','Auto Generate Dates Start - Backward','Started'
						IF(ISNULL(@increment_type,'')='' or LOWER(@increment_type)='year')
							BEGIN
								set @maxdate = CAST(DATEADD(YYYY,-@targetyear,@startdate)as DATE)
								IF(ISNULL(@increment_type,'')='')
									BEGIN
										SET @incr_type='Default Mode(Yearly)'
									END
								ELSE
									BEGIN
										set @incr_type='Yearly'
									END	
							END
						IF(LOWER(@increment_type)='month')
							BEGIN
								set @maxdate = CAST(DATEADD(MM,-@targetyear,@startdate)as DATE)
								Set @incr_type='Monthly'
							END
						IF(LOWER(@increment_type)='day')
							BEGIN
								set @maxdate = CAST(DATEADD(DD,-@targetyear,@startdate)as DATE)
								Set @incr_type='Days'
							END

						set @maxcounter = DATEDIFF(dd,@maxdate,@startdate)
						set @typename='Backward'
					END
			--set @maxdate = CAST(DATEADD(YYYY,@targetyear,@startdate)as DATE)
			--set @maxcounter = DATEDIFF(dd,@startdate,@maxdate)
			--select @maxcounter
			--select @startdate,@maxdate

			BEGIN
				BEGIN TRANSACTION
					BEGIN TRY
						INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
						VALUES
						(NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates Start - Generate','Running','SYSTEM',GETDATE())
						SET @counter = 0 --> Initial counter Position
						IF EXISTS (select 1 from AutoGeneratedDates)
							BEGIN
								SELECT @auditrecordid = [AuditRefID] from AutoGeneratedDates
								Update [dbo].[AutoGeneratedAudit] set DeleteDate = GETDATE(),ModifiedBy='SYSTEM',ModifiedDate=GETDATE()
								where [AGDID] =@auditrecordid

								TRUNCATE TABLE AutoGeneratedDates
								TRUNCATE TABLE TranSummary
							END
						WHILE (@counter < @maxcounter)
							BEGIN
								declare @refdate date 
								declare @DateId nvarchar(50) = newid()
								declare @Date nvarchar(50)
								declare @month nvarchar(50)
								declare @year nvarchar(50)
								declare @day nvarchar(50)
								--declare @fulldate nvarchar(50)
								declare @week nvarchar(50)
								--declare @AutoGenID nvarchar(50) = NEWID()
								IF(@type=1)
								BEGIN
									set @refdate = CAST(DATEADD(dd,@counter,@startdate)as DATE)
								END
								IF(@type=0)
								BEGIN
									set @refdate = CAST(DATEADD(dd,-@counter,@startdate)as DATE)
								END
					
									IF(@refdate != @maxdate)
										BEGIN
											set @Date = CONVERT(nvarchar(10),DATEPART(dd,@refdate))
											set @month = CONVERT(nvarchar(10),DATEPART(mm,@refdate))
											set @year = CONVERT(nvarchar(10),DATEPART(yy,@refdate))
											set @day = CONVERT(nvarchar(20),DATENAME(WEEKDAY,@refdate))
											set @week = CONVERT(nvarchar(10),DATEPART(WEEK,@refdate))
		
											Insert into [dbo].[AutoGeneratedDates]([DateID],[Date],[Month],[Year],[Day],[FullDate],[WeekNo],[Active],[GeneratedBy],[GeneratedDate],[AuditRefID])
											Values
											(@DateId,@Date,@month, @year,@day,@refdate,@week,1,'SYSTEM',GETDATE(),@AutoGenID)
											--select @DateId,@Date,@month, @year,@day,@refdate,@week,1,'SYSTEM',GETDATE()
								
										END
							
										SET @counter = @counter+1 --> Counter Increment
							
								--select @refdate
					
							END
							INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
							VALUES
							(NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates Start - Generate','Completed','SYSTEM',GETDATE())

							Select @refdate = MIN(fullDate) from [dbo].[AutoGeneratedDates] where AuditRefID=@AutoGenID
							Select @maxdate = MAX(fullDate) from [dbo].[AutoGeneratedDates] where AuditRefID=@AutoGenID

							Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[StartDate],[EndDate],[ProcessedRecords],[GeneratedBy],[GeneratedDate],[AutoGenType])
							Values
							(@AutoGenID,CONCAT('AVSSB-AGD-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'-SUCCESS-',RIGHT(NEWID(),3)),@startdate,@maxdate,CONVERT(int,@counter),'SYSTEM',GETDATE(),CONCAT('Auto-Generated Dates-',@incr_type,'-',@typename))
							--select NEWID(),CONCAT('AVSSB-',CAST(GETDATE() as DATE),'-SUCCESS'),@startdate,@maxdate,@counter,'SYSTEM',GETDATE(),'Auto-Generated Dates'
						BEGIN
							EXEC [dbo].[UpdatePubWeekSalProcRecords] @AutoGenID

								Select @pubholidaycounter = COUNT(1) from [dbo].[AutoGeneratedDates] where PublicHoliday=1
								Select @salcounter = COUNT(1) from [dbo].[AutoGeneratedDates]where SalaryProcessing=1
								SELECT @weekendcounter=COUNT(1) from [dbo].[AutoGeneratedDates] where Weekend=1
							
								Insert into Transummary values (CONCAT('Total Salary Dates from - ',@refdate,' - ',@maxdate),CONVERT(NVARCHAR(50),@salcounter))
								Insert into Transummary values (CONCAT('Total Public Holiday from - ',@refdate,' - ',@maxdate),CONVERT(NVARCHAR(50),@pubholidaycounter))
								Insert into Transummary values (CONCAT('Total Weekend Holidays from - ',@refdate,' - ',@maxdate),CONVERT(NVARCHAR(50),@weekendcounter))
						END
						COMMIT TRANSACTION --> Transaction Commit
							SET @transtat = 'Committed and Successful'
							SET @exec_end = GETDATE()
							SELECT @tranrefnum = [AutoGenRefID] from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AutoGenID 

					
					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION -->Transaction Rollback
							SET @transtat = 'Rolledback and failed'
							SET @exec_end = GETDATE()
							SELECT @tranrefnum = [AutoGenRefID] from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AutoGenID 
					
							Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[StartDate],[EndDate],[ProcessedRecords],[GeneratedBy],[GeneratedDate],[AutoGenType])
							Values
							(@AutoGenID,CONCAT('AVSSB-AGD-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'-FAILED',RIGHT(NEWID(),3)),@startdate,@maxdate,CONVERT(int,@counter),'SYSTEM',GETDATE(),CONCAT('Auto-Generated Dates-',@incr_type,'-',@typename))
							PRINT 'Transaction failed and Rolled-Back.'

							INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
							VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates Start - Generate','Error','SYSTEM',GETDATE())

					END CATCH
				END
		END

				PRINT 'Transaction Summary'
				PRINT '----------------------------------------------------------------------------------'
				PRINT 'Execution Start - '+CONVERT(NVARCHAR(50),@exec_start)
				PRINT ''
				IF(@transtat='Committed and Successful')
					BEGIN
						IF(@range_type=1)
							BEGIN
								PRINT 'Auto-Generation of dates from '+CONVERT(NVARCHAR(50),CAST(@date_from as DATE))+' to '+CONVERT(NVARCHAR(50),CAST(@date_to as DATE))
								SELECT @counter = COUNT(1) from AutoGeneratedDates where AuditRefID=@AutoGenID
								PRINT 'Total Rows(Dates) created = '+convert(nvarchar(50),@counter)
							END
						ELSE
							BEGIN
								IF(@type=0)
								BEGIN
									PRINT 'Auto-Generation of dates from '+CONVERT(NVARCHAR(50),CAST(@maxdate as DATE))+' to '+CONVERT(NVARCHAR(50),CAST(@refdate as DATE))
								END
								ELSE
								BEGIN
									PRINT 'Auto-Generation of dates from '+CONVERT(NVARCHAR(50),CAST(@refdate as DATE))+' to '+CONVERT(NVARCHAR(50),CAST(@maxdate as DATE))
								END				
								PRINT 'Total Rows(Dates) created = '+convert(nvarchar(50),@counter)

								IF(@type in (0,1))
								BEGIN
									PRINT 'Dates Creation Mode - '+@incr_type
								END
							END
							PRINT 'Dates Creation Type - '+@typename
						END
			
				PRINT 'Transaction Status - '+@transtat
				PRINT ''
				PRINT 'Transaction Reference# - '+@tranrefnum
				PRINT 'Transaction Audit Reference# - '+@AutoGenID
				PRINT ''
				PRINT 'Execution End - '+CONVERT(nvarchar(50),@exec_end)
				PRINT 'Total Execution Time - '+CONVERT(NVARCHAR(50),DATEDIFF(ms,@exec_start,@exec_end))+' milliseconds(s)'
				PRINT ''
				PRINT 'Execution Status - Completed...'
				PRINT 'System Status - Ready...'
	END -->Dates creation - End

	--BEGIN --> Fetch Records - Begin
	--	EXEC [Report_Get_AutoGeneratedData] 1 -->Auto Generated Dates
	--END --> Fetch Records - End

	BEGIN -->Send Email - Begin
		declare @body nvarchar(max)
		declare @subject nvarchar(100) =CONCAT('Auto Generate Dates','-AVSSB')
		declare @body_format nvarchar(100)= 'HTML'
		declare @profilename nvarchar(100)='AVSSB-AutoGenerate'
		declare @datesmessage nvarchar(max)
		declare @query nvarchar(max)
		declare @querydb nvarchar(50) = DB_NAME()
		declare @attachment_name nvarchar(100) = CONCAT('AVSSB-AGD-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'.xls') -->Excel file
		declare @queryresultseperator nvarchar(50) = '	'
		declare @queryresultnopadding int = 1
	
		
		SET @query='SELECT [Date] ''Date''
					  ,DATENAME(MM,[FullDate]) ''Month''
					  ,[Year] ''Year''
					  ,DATENAME(WEEKDAY,[FullDate]) ''Day''
					  ,[WeekNo] ''Week#''
					  ,[GeneratedBy] ''Generated By''
					  ,[GeneratedDate] ''Generated Date''
					  ,CASE WHEN [PublicHoliday]=1 THEN ''Yes'' ELSE ''No'' END ''Public Holiday''
					  ,CASE WHEN [Weekend]=1 THEN ''Yes'' ELSE ''No'' END ''Weekend Holiday''
					  ,CASE WHEN [SalaryProcessing]=1 THEN ''Yes'' ELSE ''No'' END ''Salary Processing Date''
					  ,[AuditRefID] ''Audit ID''
				  FROM [dbo].[AutoGeneratedDates] ORDER BY [FullDate]'

		IF(@range_type=1)
			BEGIN
				SET @datesmessage='Auto-Generation of dates from '+CONVERT(NVARCHAR(50),CAST(@date_from as DATE))+' to '+CONVERT(NVARCHAR(50),CAST(@date_to as DATE))
				SELECT @counter = COUNT(1) from AutoGeneratedDates where AuditRefID=@AutoGenID
				SET @typename='Range'
				
				SET @body = 'Dear User
				<br><br>
				As requested, system has auto generated the dates as per the inputs provided. Please find the transaction summary below.Please find the attachment for autogenerated results.
				<br><br>
				<strong>Transaction Summary</strong><br>
				----------------------------------<br>
				Execution Start -'+CONVERT(nvarchar(50),@exec_start)+'<br><br>
				<br>
				1.Auto Generated Dates Summary<br>
					-> ' +@datesmessage+'<br>
					-> Date Creation Type - '+@typename+'<br>
					-> Total Rows(Dates) created - '+convert(nvarchar(50),@counter)+'<br>
				<br>
				2.Transaction Reference# - '+@tranrefnum+'<br>
				3.Transaction Audit Reference# - '+@AutoGenID+'<br>
				4.Transaction Status - '+@transtat+'<br>
				<br>
				Execution End - '+CONVERT(nvarchar(50),@exec_end)+'<br>
				Total Execution Time - '+CONVERT(NVARCHAR(50),DATEDIFF(ms,@exec_start,@exec_end))+'millisecond(s)<br>
				Execution Status - Completed...<br>
				System Status - Ready...<br>
				<br>
				Regards,<br>
				AVSSB-AutoGenerate System<br>
				<hr>
				This is auto-generated mail. Replies to this mailbox are not monitored.<br>
				Responding Server - '+@@SERVERNAME	
			END
		ELSE
			BEGIN
				Select @refdate = CAST(MIN(fullDate) as Date) from [dbo].[AutoGeneratedDates] where AuditRefID=@AutoGenID
				Select @maxdate = CAST(MAX(fullDate) as Date) from [dbo].[AutoGeneratedDates] where AuditRefID=@AutoGenID

				IF(@type=0)
				BEGIN
					set @datesmessage='Auto-Generation of dates from '+CONVERT(NVARCHAR(50),CAST(@maxdate as DATE))+' to '+CONVERT(NVARCHAR(50),CAST(@refdate as DATE))
				END
				ELSE
				BEGIN
					set @datesmessage='Auto-Generation of dates from '+CONVERT(NVARCHAR(50),CAST(@refdate as DATE))+' to '+CONVERT(NVARCHAR(50),CAST(@maxdate as DATE))
				END

				SET @body = 'Dear User
				<br><br>
				As requested, system has auto generated the dates as per the inputs provided. Please find the transaction summary below.Please find the attachment for autogenerated results.
				<br><br>
				<strong>Transaction Summary</strong><br>
				----------------------------------<br>
				Execution Start -'+CONVERT(nvarchar(50),@exec_start)+'<br><br>
				<br>
				1.Auto Generated Dates Summary<br>
					-> ' +@datesmessage+'<br>
					-> Date Creation Mode - '+@incr_type+'<br>
					-> Date Creation Type - '+@typename+'<br>
					-> Total Rows(Dates) created - '+convert(nvarchar(50),@counter)+'<br>
				<br>
				2.Transaction Reference# - '+@tranrefnum+'<br>
				3.Transaction Audit Reference# - '+@AutoGenID+'<br>
				4.Transaction Status - '+@transtat+'<br>
				<br>
				Execution End - '+CONVERT(nvarchar(50),@exec_end)+'<br>
				Total Execution Time - '+CONVERT(NVARCHAR(50),DATEDIFF(ms,@exec_start,@exec_end))+'millisecond(s)<br>
				Execution Status - Completed...<br>
				System Status - Ready...<br>
				<br>
				Regards,<br>
				AVSSB-AutoGenerate System<br>
				<hr>
				This is auto-generated mail. Replies to this mailbox are not monitored.<br>
				Responding Server - '+@@SERVERNAME	

			END
		BEGIN
			EXEC [dbo].[DB_Mail_Trigger]
			@toaddress = @email,
			@cc = NULL,
			@bcc = NULL,
			@subject = @subject,
			@bodyformat = @body_format,
			@emailbody = @body,
			@query = @query,
			@querydatabase = @querydb,
			@attachmentname = @attachment_name
		END		
	END --> Send Email -End
END --> SP End
--select * from Transummary
GO
/****** Object:  StoredProcedure [dbo].[AutoGenerateNames]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================================
-- Author:		Sai Bhargav Abburu
-- Create date: Nov 25, 2020
-- Description:	Auto Generate Names using Target count
-- ==============================================================================================
-- EXEC [dbo].[AutoGenerateNames] 1000,'B',1,'ibhargav547@gmail.com'
--
--@targetcount = no. of records need to generate.
--@gendr = 'M'-->Male|'F'-->Female|'B'-->Both ---> DEFAULT IS 'B'-->Both
--@emailnotify = 1-->Send Email | 0--> No Email will be sent   --> DEFAULT IS 1 --> Email Send
--@emailid = Email ID Required
-- ==============================================================================================
CREATE PROCEDURE [dbo].[AutoGenerateNames] @targetcount int,@gendr char(2),@emailnotify bit,@emailid nvarchar(100)
AS
BEGIN
	BEGIN-->Auto Generate Name Start
		SET NOCOUNT ON;

		BEGIN TRANSACTION
		BEGIN TRY
			declare @fname_rand int
			declare @lname_rand int
			declare @counter int
			declare @first_name nvarchar(50)
			declare @last_name nvarchar(50)
			declare @gender nvarchar(10)
			declare @phone nvarchar(50)
			declare @addnumber int
			declare @email nvarchar(50)
			declare @regnum nvarchar(50)
			declare @AuditRefID nvarchar(100)
			declare @auditrecordid nvarchar(100)
			declare @exec_start datetime = GETDATE()
			declare @exec_end datetime 
			declare @transtat nvarchar(50)
			declare @availcounter int
			declare @runcounter int
			declare @rowcounter int
			declare @credstartcounter int
			declare @credendcounter int
			declare @pwdprocessid nvarchar(50)

			SET @AuditRefID = CONCAT('AVSSB-AUDIT-',RIGHT(NEWID(),5))

			INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
			VALUES
			(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start','Received','SYSTEM',GETDATE())

			select * into #tempusers from [MVCframe].[dbo].[Users]
			CREATE TABLE #autogen(first_name nvarchar(50),last_name nvarchar(50),gender nvarchar(10),phone nvarchar(50),row_num int)
			
			Insert into #autogen(first_name,last_name,gender,phone,row_num)
			select ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_number()over(order by first_name) from #tempusers

			SET @counter = 0 --> Initial Counter
			SET @runcounter = 0 

			INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
			VALUES
			(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start','Processing','SYSTEM',GETDATE())

			INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
			VALUES
			(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Truncate Table','Started','SYSTEM',GETDATE())

			IF EXISTS (select 1 from AutoGeneratedNames)
			BEGIN
				SELECT @auditrecordid = [AuditRefID] from AutoGeneratedNames
				Update [dbo].[AutoGeneratedAudit] set DeleteDate = GETDATE(),ModifiedBy='SYSTEM',ModifiedDate=GETDATE()
				where [AGDID] =@auditrecordid

				TRUNCATE TABLE AutoGeneratedNames

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Truncate Table','Completed','SYSTEM',GETDATE())
			END

			IF(@gendr='M')-->Male While Start
			BEGIN
				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Male','Started','SYSTEM',GETDATE())

				DELETE FROM #autogen where gender='Female'
				Select @availcounter=COUNT(*) from #autogen

				IF(@availcounter < @targetcount)
				BEGIN

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Male','Record Multiply Started','SYSTEM',GETDATE())

					WHILE (@runcounter != @targetcount)
					BEGIN
						IF(@runcounter>@targetcount)
							BREAK;
						ELSE
							Insert into #autogen
							select ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num from #autogen
							Select @rowcounter=COUNT(*) from #autogen

						SET @runcounter=@runcounter+@rowcounter
					END

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Male','Record Multiply Completed','SYSTEM',GETDATE())

				END

				WHILE(@targetcount > @counter)
				BEGIN
					SET @fname_rand = CEILING(RAND()*(1000+5)+5) 
				
					IF(@fname_rand > @targetcount)
						BEGIN
							WHILE len(@fname_rand) > len(@targetcount)
							BEGIN
								SET @fname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@fname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @fname_rand = CEILING(RAND()*(1000+5)+5)
							END
						END
				
					SET @lname_rand = CEILING(RAND()*(1000+5)+5)
				
					IF(@lname_rand > @targetcount)
						BEGIN
							WHILE len(@lname_rand) > len(@targetcount)
							BEGIN
								SET @lname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@lname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @lname_rand = CEILING(RAND()*(1000+5)+5)
							END
					
						END

					SET @gender='Male'
			
					SELECT @first_name = first_name from #autogen where row_num = @fname_rand
					SELECT @last_name = last_name from #autogen where row_num = @lname_rand
					SET @regnum = CONCAT('UR-AVS-',LEFT(@gender,1),'-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand))
					SET @email = LOWER(CONCAT(CONVERT(nvarchar(50),ISNULL(@first_name,'Sys')),'.',CONVERT(nvarchar(50),ISNULL(@last_name,'Sys')),CONVERT(nvarchar(50),@fname_rand),'@avssb.com'))
					SET @email = REPLACE(@email,'-','.')
					SET @email = REPLACE(@email,' ','.')
					SET @phone = CONCAT(CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = LEFT(@phone,10)
						IF (len(@phone) < 10)
							BEGIN
								SET @addnumber = 10-len(@phone)
								SET @phone = CONCAT(@phone,RIGHT(CEILING(RAND()*(100000+5)+5),@addnumber))
								SET @phone = LEFT(@phone,10)
								
							END

					Insert Into [dbo].[AutoGeneratedNames]([RegNo],[first_name],[last_name],[gender],[email],[phone],[Active],[CreatedBy],[CreatedDate],[AuditRefID])
					Values
					(@regnum,ISNULL(@first_name,'Sys'),ISNULL(@last_name,'Sys'),@gender,@email,'91-'+@phone,1,'SYSTEM',GETDATE(),@AuditRefID)
				
					SET @counter = @counter+1
				END -->Male While End

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Male','Completed','SYSTEM',GETDATE())
			END
			IF(@gendr='F')-->Female While Start
			BEGIN
				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Female','Started','SYSTEM',GETDATE())

				DELETE FROM #autogen where gender='Male'

				Select @availcounter=COUNT(*) from #autogen

				IF(@availcounter < @targetcount)
				BEGIN
					INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
					VALUES
					(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Female','Record Multiply Started','SYSTEM',GETDATE())

					WHILE (@runcounter != @targetcount)
					BEGIN
						IF(@runcounter>@targetcount)
							BREAK;
						ELSE
							Insert into #autogen
							select ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num from #autogen
							Select @rowcounter=COUNT(*) from #autogen

						SET @runcounter=@runcounter+@rowcounter
					END

					INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
					VALUES
					(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Female','Record Multiply Completed','SYSTEM',GETDATE())
				END

				WHILE(@targetcount > @counter)
				BEGIN
					SET @fname_rand = CEILING(RAND()*(1000+5)+5) 
				
					IF(@fname_rand > @targetcount)
						BEGIN
							WHILE len(@fname_rand) > len(@targetcount)
							BEGIN
								SET @fname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@fname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @fname_rand = CEILING(RAND()*(1000+5)+5)
							END
						END
				
					SET @lname_rand = CEILING(RAND()*(1000+5)+5)
				
					IF(@lname_rand > @targetcount)
						BEGIN
							WHILE len(@lname_rand) > len(@targetcount)
							BEGIN
								SET @lname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@lname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @lname_rand = CEILING(RAND()*(1000+5)+5)
							END
					
						END

					SET @gender='Female'
			
					SELECT @first_name = first_name from #autogen where row_num = @fname_rand
					SELECT @last_name = last_name from #autogen where row_num = @lname_rand
					SET @regnum = CONCAT('UR-AVS-',LEFT(@gender,1),'-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand))
					SET @email = LOWER(CONCAT(CONVERT(nvarchar(50),ISNULL(@first_name,'Sys')),'.',CONVERT(nvarchar(50),ISNULL(@last_name,'Sys')),CONVERT(nvarchar(50),@fname_rand),'@avssb.com'))
					SET @email = REPLACE(@email,'-','.')
					SET @email = REPLACE(@email,' ','.')
					--SET @phone = CONCAT('91-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = CONCAT(CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = LEFT(@phone,10)
						IF (len(@phone) < 10)
							BEGIN
								SET @addnumber = 10-len(@phone)
								SET @phone = CONCAT(@phone,RIGHT(CEILING(RAND()*(100000+5)+5),@addnumber))
								SET @phone = LEFT(@phone,10)
								
							END

					Insert Into [dbo].[AutoGeneratedNames]([RegNo],[first_name],[last_name],[gender],[email],[phone],[Active],[CreatedBy],[CreatedDate],[AuditRefID])
					Values
					(@regnum,ISNULL(@first_name,'Sys'),ISNULL(@last_name,'Sys'),@gender,@email,'91-'+@phone,1,'SYSTEM',GETDATE(),@AuditRefID)
				
					SET @counter = @counter+1
				END -->Female While End

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Female','Completed','SYSTEM',GETDATE())
			END

			IF(ISNULL(@gendr,'')='' or @gendr='B')-->Both Gender While Start
			BEGIN
				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Both','Started','SYSTEM',GETDATE())

				Select @availcounter=COUNT(*) from #autogen

				IF(@availcounter < @targetcount)
				BEGIN
					INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
					VALUES
					(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Both','Record Multiply Started','SYSTEM',GETDATE())

					WHILE (@runcounter != @targetcount)
					BEGIN
						IF(@runcounter>@targetcount)
							BREAK;
						ELSE
							Insert into #autogen
							select ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num from #autogen
							Select @rowcounter=COUNT(*) from #autogen

						SET @runcounter=@runcounter+@rowcounter
					END

					INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
					VALUES
					(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Both','Record Multiply Completed','SYSTEM',GETDATE())
				END

				WHILE(@targetcount > @counter)
				BEGIN
					SET @fname_rand = CEILING(RAND()*(1000+5)+5) 
				
					IF(@fname_rand > @targetcount)
						BEGIN
							WHILE len(@fname_rand) > len(@targetcount)
							BEGIN
								SET @fname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@fname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @fname_rand = CEILING(RAND()*(1000+5)+5)
							END
						END
				
					SET @lname_rand = CEILING(RAND()*(1000+5)+5)
				
					IF(@lname_rand > @targetcount)
						BEGIN
							WHILE len(@lname_rand) > len(@targetcount)
							BEGIN
								SET @lname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@lname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @lname_rand = CEILING(RAND()*(1000+5)+5)
							END
					
						END

					IF(((@fname_rand+@lname_rand)%2) = 0)
						BEGIN
							SET @gender = 'Male'
						END
					ELSE
						BEGIN
							SET @gender = 'Female'
						END
			
					SELECT @first_name = first_name from #autogen where row_num = @fname_rand
					SELECT @last_name = last_name from #autogen where row_num = @lname_rand
					SET @regnum = CONCAT('UR-AVS-',LEFT(@gender,1),'-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand))
					SET @email = LOWER(CONCAT(CONVERT(nvarchar(50),ISNULL(@first_name,'Sys')),'.',CONVERT(nvarchar(50),ISNULL(@last_name,'Sys')),CONVERT(nvarchar(50),@fname_rand),'@avssb.com'))
					SET @email = REPLACE(@email,'-','.')
					SET @email = REPLACE(@email,' ','.')
					--SET @phone = CONCAT('91-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = CONCAT(CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = LEFT(@phone,10)
						IF (len(@phone) < 10)
							BEGIN
								SET @addnumber = 10-len(@phone)
								SET @phone = CONCAT(@phone,RIGHT(CEILING(RAND()*(100000+5)+5),@addnumber))
								SET @phone = LEFT(@phone,10)
								
							END

					Insert Into [dbo].[AutoGeneratedNames]([RegNo],[first_name],[last_name],[gender],[email],[phone],[Active],[CreatedBy],[CreatedDate],[AuditRefID])
					Values
					(@regnum,ISNULL(@first_name,'Sys'),ISNULL(@last_name,'Sys'),@gender,@email,'91-'+@phone,1,'SYSTEM',GETDATE(),@AuditRefID)
				
					SET @counter = @counter+1
				END -->Both While End

				UPDATE [AutoGeneratedNames]
				SET [RegNo] = IIF(
								LEN(RegNo)=16,
									RegNo ,-->Execute when TRUE CONDITION
									CONCAT( 
											LEFT(RegNo,9),
											REPLICATE('0',(7-((LEN(RegNo)-LEN('UR-AVS-F-'))))),RIGHT(RegNo,(LEN(RegNo)-LEN('UR-AVS-F-')))
										) -->Execute when FALSE CONDITION
								) --> Update End

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start - Both','Completed','SYSTEM',GETDATE())
			END
		
				Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[GeneratedBy],[GeneratedDate],[AutoGenType],[ProcessedRecords])
				Values (@AuditRefID,CONCAT('AVSSB-AGN-',CASE WHEN @gendr='M' THEN 'M-'
															 WHEN @gendr='F' THEN 'F-'
															 ELSE 'B-' END,DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-SUCCESS'),'SYSTEM',GETDATE(),'Auto-Generated Names',@counter)
			
				PRINT 'Total Rows(Names) created = '+convert(nvarchar(50),@counter)
				PRINT 'Transaction Successful and Committed.'
					
				SELECT [AutoGenRefID] 'Auto Generated Ref ID' from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AuditRefID 

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names End','Completed','SYSTEM',GETDATE())

				-->Credentials Generate START

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names','Forwarded','SYSTEM',GETDATE())

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Credentials','Received','SYSTEM',GETDATE())

				Select RegNo,ROW_NUMBER()OVER(ORDER BY RegNo) row_num into #pwdtemp from AutoGeneratedNames

				Select @credstartcounter = MIN(row_num) from #pwdtemp
				Select @credendcounter = MAX(row_num) from #pwdtemp

				WHILE(@credstartcounter<=@credendcounter)
				BEGIN
					Select @pwdprocessid = RegNo from #pwdtemp where row_num = @credstartcounter

					EXEC [dbo].[Generate_Initial_Credentials] @pwdprocessid

					SET @credstartcounter = @credstartcounter+1
				END

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Credentials','Completed','SYSTEM',GETDATE())

				Delete from Login_Credentials where Credentials_Ref_ID NOT IN (Select Login_Cred_Ref_Num from AutoGeneratedNames where Active=1)

				-->Credentials Generate END

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Credentials','Forwarded to Mailsystem','SYSTEM',GETDATE())
		
			COMMIT TRANSACTION

			SET @exec_end=GETDATE()
			SET @transtat='Comitted and Successful.'

			DROP TABLE #autogen,#tempusers
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION

			SET @exec_end=GETDATE()
			SET @transtat='Rolledback and failed.'

			INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names End','Error','SYSTEM',GETDATE())

			Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[GeneratedBy],[GeneratedDate],[AutoGenType],[ProcessedRecords])
				Values (@AuditRefID,CONCAT('AVSSB-AGN-',CASE WHEN @gendr='M' THEN 'M-'
															 WHEN @gendr='F' THEN 'F-'
															 ELSE 'B' END,DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-FAILED'),'SYSTEM',GETDATE(),'Auto-Generated Names',NULL)
		
			PRINT 'Transaction failed and Rolled-Back.'
			SELECT [AutoGenRefID] 'Auto Generated Ref ID' from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AuditRefID 

		END CATCH	

		BEGIN --> Fetch Records - Begin
			EXEC [Get_AutoGeneratedData] 2 -->Auto Generated Names
		END --> Fetch Records - End

	END--Auto Generate Name End
IF(ISNULL(@emailnotify,1)=1)
BEGIN -->Send Email - Begin
	INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
	VALUES
	(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Mail System','Received by Mailsystem','SYSTEM',GETDATE())

	INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
	VALUES
	(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Mail System','Mail Builder Started','SYSTEM',GETDATE())

	BEGIN 
		declare @body nvarchar(max)
		declare @subject nvarchar(100) =CONCAT('Auto Generate Names','-AVSSB')
		declare @body_format nvarchar(100)= 'HTML'
		declare @profilename nvarchar(100)='AVSSB-AutoGenerate'
		declare @datesmessage nvarchar(max)
		declare @query nvarchar(max)
		declare @querydb nvarchar(50) = 'TestDatabase'
		declare @attachment_name nvarchar(100) = CONCAT('AVSSB-AGN-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'.xls') -->Excel file
		declare @queryresultseperator nvarchar(50) = '	'
		declare @queryresultnopadding int = 1
		declare @tranRef# nvarchar(50)
		declare @gendercount int
		declare @gendercountm int
		declare @gendercountf int

		select @tranRef# = [AutoGenRefID] from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AuditRefID 

		IF(@gendr='M')
			BEGIN
				SELECT @gendercount = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where AuditRefID = @AuditRefID 
			END
		ELSE IF(@gendr='F')
			BEGIN
				SELECT @gendercount = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where AuditRefID = @AuditRefID 
			END
		ELSE
			BEGIN
				SELECT @gendercountm = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where gender='Male' and AuditRefID = @AuditRefID
				SELECT @gendercountf = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where gender='Female' and AuditRefID = @AuditRefID 
			END
		
		SET @query='SELECT RegNo ''Registration#'',last_name+'', ''+first_name ''User Name'',gender ''Gender'',email ''E-mail''
		,CONVERT(VARCHAR(20),phone) ''Phone'',Createdby ''Created By'',CONVERT(NVARCHAR(50),CreatedDate) ''Created Date''
		,Login_Cred_Ref_Num ''Login Credentials Reference#''
		from [dbo].[AutoGeneratedNames]'
		
		IF(@gendr='B')
			BEGIN
			SET @body = 'Dear User,
			<br><br>
			As requested, system has auto generated the names as per the inputs provided. Please find the transaction summary below.Please find the attachment for autogenerated results.
			<br><br>
			<strong>Transaction Summary</strong><br>
			----------------------------------<br>
			Execution Start -'+CONVERT(nvarchar(50),@exec_start)+'<br>
			<br>
			<strong>1.Auto Generated Names Summary<br></strong>
				     -> Total Rows(Names) created - '+convert(NVARCHAR(50),@counter)+'<br>
				     -> Transaction Type - Both(Male&Female) or Default Type<br>
				     -> Total Male Users - '+CONVERT(NVARCHAR(10),@gendercountm)+'.<br>
				     -> Total Female Users - '+CONVERT(NVARCHAR(10),@gendercountf)+'<br>
			<br>
			<strong>2.Transaction Reference# - '+@tranRef#+'<br></strong>
			<strong>3.Transaction Audit Reference# - '+@AuditRefID+'<br></strong>
			<strong>4.Transaction Status - '+@transtat+'<br></strong>
			<br>
			Execution End - '+CONVERT(NVARCHAR(50),@exec_end)+'<br>
			Total Execution Time - '+CONVERT(NVARCHAR(50),DATEDIFF(ms,@exec_start,@exec_end))+'millisecond(s)<br><br>
			Execution Status - Completed...<br>
			System Status - Ready...<br>
			<br>
			<strong>
			Regards,<br>
			AVSSB-AutoGenerate System<br>
			</strong>
			<hr>
			This is auto-generated mail. Replies to this mailbox are not monitored.<br>
			Responding Server - '+@@SERVERNAME
			END
		ELSE
			BEGIN
			SET @body = 'Dear User,
				<br><br>
				As requested, system has auto generated the names as per the inputs provided. Please find the transaction summary below.Please find the attachment for autogenerated results.
				<br><br>
				<strong>Transaction Summary</strong><br>
				----------------------------------<br>
				Execution Start -'+CONVERT(nvarchar(50),@exec_start)+'<br>
				<br>
				<strong>1.Auto Generated Names Summary<br></strong>
					-> Total Rows(Names) created - '+convert(nvarchar(50),@counter)+'<br>
					-> Transaction Type -'+@gender+'<br>
					-> Total Users('+@gender+') - '+CONVERT(NVARCHAR(10),@gendercount)+'.<br>
				<br>
				<strong>2.Transaction Reference# - '+@tranRef#+'<br></strong>
				<strong>3.Transaction Audit Reference# - '+@AuditRefID+'<br></strong>
				<strong>4.Transaction Status - '+@transtat+'<br></strong>
				<br>
				Execution End - '+CONVERT(nvarchar(50),@exec_end)+'<br>
				Total Execution Time - '+CONVERT(NVARCHAR(50),DATEDIFF(ms,@exec_start,@exec_end))+'millisecond(s)<br><br>
				Execution Status - Completed...<br>
				System Status - Ready...<br>
				<br>
				<strong>
				Regards,<br>
				AVSSB-AutoGenerate System<br>
				</strong>
				<hr>
				This is auto-generated mail. Replies to this mailbox are not monitored.<br>
				Responding Server - '+@@SERVERNAME
			END
		INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
		VALUES
		(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Mail System','Mail Builder Completed','SYSTEM',GETDATE())
		BEGIN
			BEGIN TRY
				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Mail System','Mail Sender Started','SYSTEM',GETDATE())

				EXEC msdb.dbo.sp_send_dbmail 
					@profile_name=@profilename,
					@recipients = @emailid,
					@body_format=@body_format,
					@body=@body,
					@query=@query,
					@execute_query_database = @querydb,
					@attach_query_result_as_file = 1,
					@query_attachment_filename=@attachment_name,
					@query_result_separator=@queryresultseperator,
					@query_result_no_padding=@queryresultnopadding,
					@subject=@subject,
					@importance = 'High',
					@sensitivity='Confidential',
					@query_result_header=1,
					@exclude_query_output =0

				PRINT 'Email sent to '+@emailid
				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES
				(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Mail System','Mail Sender Ended','SYSTEM',GETDATE())
			END TRY
			BEGIN CATCH
				PRINT 'Email Sending Failed'
			END CATCH
		END
	END
END --> Send Email -End
			INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
			VALUES
			(NEWID(),@AuditRefID,'[dbo].[AutoGeneratedNames]','Auto Generate Names Start','Completed','SYSTEM',GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[BK_AutoGenerateNames]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================================
-- Author:		Sai Bhargav Abburu
-- Create date: Nov 24, 2020
-- Description:	Auto Generate Names using Target count
-- ==============================================================================================
-- EXEC [dbo].[AutoGenerateNames] 1000,'B',0,'maseratibhargav@outlook.com'
--
--@targetcount = no. of records need to generate.
--@gendr = 'M'-->Male|'F'-->Female|'B'-->Both ---> DEFAULT IS 'B'-->Both
--@emailnotify = 1-->Send Email | 0--> No Email will be sent   --> DEFAULT IS 1 --> Email Send
--@emailid = Email ID Required
-- ==============================================================================================
CREATE PROCEDURE [dbo].[BK_AutoGenerateNames] @targetcount int,@gendr char(2),@emailnotify bit,@emailid nvarchar(100)
AS
BEGIN
	BEGIN-->Auto Generate Name Start
		SET NOCOUNT ON;

		BEGIN TRANSACTION
		BEGIN TRY
			declare @fname_rand int
			declare @lname_rand int
			declare @counter int
			declare @first_name nvarchar(50)
			declare @last_name nvarchar(50)
			declare @gender nvarchar(10)
			declare @phone nvarchar(50)
			declare @addnumber int
			declare @email nvarchar(50)
			declare @regnum nvarchar(50)
			declare @AuditRefID nvarchar(100)
			declare @auditrecordid nvarchar(100)
			declare @exec_start datetime = GETDATE()
			declare @exec_end datetime 
			declare @transtat nvarchar(50)
			declare @availreccount int
			declare @tablecounter int
			declare @rowcounter int
			declare @numtogenerate int
			declare @inc_mode int

			select * into #tempusers from [MVCframe].[dbo].[Users]
			CREATE TABLE #autogen(first_name nvarchar(50),last_name nvarchar(50),gender nvarchar(10),phone nvarchar(50),row_num int)

			Insert into #autogen(first_name,last_name,gender,phone,row_num)
			select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_number()over(order by first_name) from #tempusers

			SET @counter = 0 --> Initial Counter Setting
			SET @tablecounter = 0 -->Initail Table Counter Setting
			SET @AuditRefID = CONCAT('AVSSB-AUDIT-',RIGHT(NEWID(),5))
			SET @numtogenerate = 0 --> Initial No.Records to generate counter setting

			IF EXISTS (select 1 from AutoGeneratedNames)
			BEGIN
				SELECT @auditrecordid = [AuditRefID] from AutoGeneratedNames
				Update [dbo].[AutoGeneratedAudit] set DeleteDate = GETDATE(),ModifiedBy='SYSTEM',ModifiedDate=GETDATE()
				where [AGDID] =@auditrecordid

				TRUNCATE TABLE AutoGeneratedNames
			END

			IF(@gendr='M')-->Male While Start
			BEGIN
				DELETE FROM #autogen where gender='Female'
				SELECT @availreccount = COUNT(1) from #autogen
				
				IF(@availreccount < @targetcount)
				BEGIN
					SET @numtogenerate = @targetcount-@availreccount
					
					IF(@numtogenerate < 500)
					BEGIN
						WHILE(@tablecounter < @targetcount)
						BEGIN
							SET @inc_mode = @tablecounter%2
							IF(@inc_mode=0) --> Descending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num 
								from #autogen order by row_num desc

								SELECT @rowcounter = COUNT(row_num) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
							IF(@inc_mode <> 0) --> Ascending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num
								from #autogen order by row_num asc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
						SET @tablecounter = ISNULL(@tablecounter,0)+@rowcounter
						END
					END
					IF(@numtogenerate < 500)
					BEGIN
						WHILE(@tablecounter < @targetcount)
						BEGIN
							SET @inc_mode = @tablecounter%2
							IF(@inc_mode=0) --> Descending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num 
								from #autogen order by row_num desc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
							IF(@inc_mode <> 0) --> Ascending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num
								from #autogen order by row_num asc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
						SET @tablecounter = ISNULL(@tablecounter,0)+@rowcounter
						END
					END
				END
				WHILE(@targetcount > @counter)
				BEGIN
					SET @fname_rand = CEILING(RAND()*(1000+5)+5) 
				
					IF(@fname_rand > @targetcount)
						BEGIN
							WHILE len(@fname_rand) > len(@targetcount)
							BEGIN
								SET @fname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@fname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @fname_rand = CEILING(RAND()*(1000+5)+5)
							END
						END
				
					SET @lname_rand = CEILING(RAND()*(1000+5)+5)
				
					IF(@lname_rand > @targetcount)
						BEGIN
							WHILE len(@lname_rand) > len(@targetcount)
							BEGIN
								SET @lname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@lname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @lname_rand = CEILING(RAND()*(1000+5)+5)
							END
					
						END

					SET @gender='Male'
			
					SELECT @first_name = first_name from #autogen where row_num = @fname_rand
					SELECT @last_name = last_name from #autogen where row_num = @lname_rand
					SET @regnum = CONCAT('UR-AVS-',LEFT(@gender,1),'-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand))
					SET @email = LOWER(CONCAT(CONVERT(nvarchar(50),ISNULL(@first_name,'Sys')),'.',CONVERT(nvarchar(50),ISNULL(@last_name,'Sys')),CONVERT(nvarchar(50),@fname_rand),'@avssb.com'))
					SET @email = REPLACE(@email,'-','.')
					SET @email = REPLACE(@email,' ','.')
					SET @phone = CONCAT(CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = LEFT(@phone,10)
						IF (len(@phone) < 10)
							BEGIN
								SET @addnumber = 10-len(@phone)
								SET @phone = CONCAT(@phone,RIGHT(CEILING(RAND()*(100000+5)+5),@addnumber))
								SET @phone = LEFT(@phone,10)
								
							END

					Insert Into [dbo].[AutoGeneratedNames]([RegNo],[first_name],[last_name],[gender],[email],[phone],[Active],[CreatedBy],[CreatedDate],[AuditRefID])
					Values
					(@regnum,ISNULL(@first_name,'Sys'),ISNULL(@last_name,'Sys'),@gender,@email,'91-'+@phone,1,'SYSTEM',GETDATE(),@AuditRefID)
				
					SET @counter = @counter+1
				END -->Male While End
			END
			IF(@gendr='F')-->Female While Start
			BEGIN
				DELETE FROM #autogen where gender='Male'
				SELECT @availreccount = COUNT(1) from #autogen
				
				IF(@availreccount < @targetcount)
				BEGIN
					SET @numtogenerate = @targetcount-@availreccount
					
					IF(@numtogenerate < 500)
					BEGIN
						WHILE(@tablecounter < @targetcount)
						BEGIN
							SET @inc_mode = @tablecounter%2
							IF(@inc_mode=0) --> Descending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num 
								from #autogen order by row_num desc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
							IF(@inc_mode <> 0) --> Ascending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num
								from #autogen order by row_num asc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
						SET @tablecounter = ISNULL(@tablecounter,0)+@rowcounter
						END
					END
					IF(@numtogenerate < 500)
					BEGIN
						WHILE(@tablecounter < @targetcount)
						BEGIN
							SET @inc_mode = @tablecounter%2
							IF(@inc_mode=0) --> Descending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num 
								from #autogen order by row_num desc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
							IF(@inc_mode <> 0) --> Ascending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num
								from #autogen order by row_num asc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
						SET @tablecounter = ISNULL(@tablecounter,0)+@rowcounter
						END
					END
				END
				WHILE(@targetcount > @counter)
				BEGIN
					SET @fname_rand = CEILING(RAND()*(1000+5)+5) 
				
					IF(@fname_rand > @targetcount)
						BEGIN
							WHILE len(@fname_rand) > len(@targetcount)
							BEGIN
								SET @fname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@fname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @fname_rand = CEILING(RAND()*(1000+5)+5)
							END
						END
				
					SET @lname_rand = CEILING(RAND()*(1000+5)+5)
				
					IF(@lname_rand > @targetcount)
						BEGIN
							WHILE len(@lname_rand) > len(@targetcount)
							BEGIN
								SET @lname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@lname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @lname_rand = CEILING(RAND()*(1000+5)+5)
							END
					
						END

					SET @gender='Female'
			
					SELECT @first_name = first_name from #autogen where row_num = @fname_rand
					SELECT @last_name = last_name from #autogen where row_num = @lname_rand
					SET @regnum = CONCAT('UR-AVS-',LEFT(@gender,1),'-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand))
					SET @email = LOWER(CONCAT(CONVERT(nvarchar(50),ISNULL(@first_name,'Sys')),'.',CONVERT(nvarchar(50),ISNULL(@last_name,'Sys')),CONVERT(nvarchar(50),@fname_rand),'@avssb.com'))
					SET @email = REPLACE(@email,'-','.')
					SET @email = REPLACE(@email,' ','.')
					SET @phone = CONCAT(CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = LEFT(@phone,10)
						IF (len(@phone) < 10)
							BEGIN
								SET @addnumber = 10-len(@phone)
								SET @phone = CONCAT(@phone,RIGHT(CEILING(RAND()*(100000+5)+5),@addnumber))
								SET @phone = LEFT(@phone,10)
								
							END

					Insert Into [dbo].[AutoGeneratedNames]([RegNo],[first_name],[last_name],[gender],[email],[phone],[Active],[CreatedBy],[CreatedDate],[AuditRefID])
					Values
					(@regnum,ISNULL(@first_name,'Sys'),ISNULL(@last_name,'Sys'),@gender,@email,'91-'+@phone,1,'SYSTEM',GETDATE(),@AuditRefID)
				
					SET @counter = @counter+1
				END -->Female While End
			END

			IF(ISNULL(@gendr,'')='' or @gendr='B')-->Both Gender While Start
			BEGIN
				SELECT @availreccount = COUNT(1) from #autogen

				IF(@availreccount < @targetcount)
				BEGIN
				SET @numtogenerate = @targetcount-@availreccount
					
					IF(@numtogenerate < 500)
					BEGIN
						WHILE(@tablecounter < @targetcount)
						BEGIN
							SET @inc_mode = @tablecounter%2
							IF(@inc_mode=0) --> Descending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num 
								from #autogen order by row_num desc

								SELECT @rowcounter = COUNT(*) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
							IF(@inc_mode <> 0) --> Ascending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num
								from #autogen order by row_num asc

								SELECT @rowcounter = COUNT(*) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
						SET @tablecounter = ISNULL(@tablecounter,0)+@rowcounter
						END
					END
					IF(@numtogenerate < 500)
					BEGIN
						WHILE(@tablecounter < @targetcount)
						BEGIN
							SET @inc_mode = @tablecounter%2
							IF(@inc_mode=0) --> Descending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num 
								from #autogen order by row_num desc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
							IF(@inc_mode <> 0) --> Ascending Order Addition
							BEGIN
								Insert into #autogen(first_name,last_name,gender,phone,row_num)
								select top 500 ISNULL(first_name,'Sys'),ISNULL(last_name,'Sys'),gender,convert(nvarchar(50),phone),row_num
								from #autogen order by row_num asc

								SELECT @rowcounter = COUNT(1) from #autogen
								IF(@rowcounter > @targetcount)
								BREAK;
							END
						SET @tablecounter = ISNULL(@tablecounter,0)+@rowcounter
						END
					END
				END

				WHILE(@targetcount > @counter)
				BEGIN
					SET @fname_rand = CEILING(RAND()*(1000+5)+5) 
				
					IF(@fname_rand > @targetcount)
						BEGIN
							WHILE len(@fname_rand) > len(@targetcount)
							BEGIN
								SET @fname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@fname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @fname_rand = CEILING(RAND()*(1000+5)+5)
							END
						END
				
					SET @lname_rand = CEILING(RAND()*(1000+5)+5)
				
					IF(@lname_rand > @targetcount)
						BEGIN
							WHILE len(@lname_rand) > len(@targetcount)
							BEGIN
								SET @lname_rand = CEILING(RAND()*(1000+5)+5)
									IF(@lname_rand <= @targetcount)
									BREAK;
									ELSE
									SET @lname_rand = CEILING(RAND()*(1000+5)+5)
							END
					
						END

					IF(((@fname_rand+@lname_rand)%2) = 0)
						BEGIN
							SET @gender = 'Male'
						END
					ELSE
						BEGIN
							SET @gender = 'Female'
						END
			
					SELECT @first_name = first_name from #autogen where row_num = @fname_rand
					SELECT @last_name = last_name from #autogen where row_num = @lname_rand
					SET @regnum = CONCAT('UR-AVS-',LEFT(@gender,1),'-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand))
					SET @email = LOWER(CONCAT(CONVERT(nvarchar(50),ISNULL(@first_name,'Sys')),'.',CONVERT(nvarchar(50),ISNULL(@last_name,'Sys')),CONVERT(nvarchar(50),@fname_rand),'@avssb.com'))
					SET @email = REPLACE(@email,'-','.')
					SET @email = REPLACE(@email,' ','.')
					--SET @phone = CONCAT('91-',CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = CONCAT(CONVERT(nvarchar(50),@fname_rand),CONVERT(nvarchar(50),@lname_rand),CEILING(RAND()*(1000+5)+5),CEILING(RAND()*(1000+5)+5))
					SET @phone = LEFT(@phone,10)
						IF (len(@phone) < 10)
							BEGIN
								SET @addnumber = 10-len(@phone)
								SET @phone = CONCAT(@phone,RIGHT(CEILING(RAND()*(100000+5)+5),@addnumber))
								SET @phone = LEFT(@phone,10)
								
							END

					Insert Into [dbo].[AutoGeneratedNames]([RegNo],[first_name],[last_name],[gender],[email],[phone],[Active],[CreatedBy],[CreatedDate],[AuditRefID])
					Values
					(@regnum,ISNULL(@first_name,'Sys'),ISNULL(@last_name,'Sys'),@gender,@email,'91-'+@phone,1,'SYSTEM',GETDATE(),@AuditRefID)
				
					SET @counter = @counter+1
				END -->Both While End
			END
		
				Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[GeneratedBy],[GeneratedDate],[AutoGenType],[ProcessedRecords])
				Values (@AuditRefID,CONCAT('AVSSB-AGN-',CASE WHEN @gendr='M' THEN 'M-'
															 WHEN @gendr='F' THEN 'F-'
															 ELSE 'B-' END,DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-SUCCESS'),'SYSTEM',GETDATE(),'Auto-Generated Names',@counter)
			
				PRINT 'Total Rows(Names) created = '+convert(nvarchar(50),@counter)
				PRINT 'Transaction Successful and Committed.'
				PRINT 'Total Records Available for Processing - '+CONVERT(NVARCHAR(50),ISNULL(@availreccount,''))
				PRINT 'Total Records to be created - '+CONVERT(NVARCHAR(50),ISNULL(@numtogenerate,''))
				
					
				SELECT [AutoGenRefID] 'Auto Generated Ref ID' from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AuditRefID 
		
			COMMIT TRANSACTION

			SET @exec_end=GETDATE()
			SET @transtat='Comitted and Successful.'
			select @rowcounter = COUNT(1) from #autogen
			
			DROP TABLE #autogen,#tempusers
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION

			SET @exec_end=GETDATE()
			SET @transtat='Rolledback and failed.'

			Insert Into [dbo].[AutoGeneratedAudit]([AGDID],[AutoGenRefID],[GeneratedBy],[GeneratedDate],[AutoGenType],[ProcessedRecords])
				Values (@AuditRefID,CONCAT('AVSSB-AGN-',CASE WHEN @gendr='M' THEN 'M-'
															 WHEN @gendr='F' THEN 'F-'
															 ELSE 'B' END,DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-FAILED'),'SYSTEM',GETDATE(),'Auto-Generated Names',NULL)
		
			PRINT 'Transaction failed and Rolled-Back.'
			SELECT [AutoGenRefID] 'Auto Generated Ref ID' from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AuditRefID 

		END CATCH	

		BEGIN --> Fetch Records - Begin
			EXEC [Get_AutoGeneratedData] 2 -->Auto Generated Names
		END --> Fetch Records - End
	END--Auto Generate Name End

IF(ISNULL(@emailnotify,1)=1)
	BEGIN -->Send Email - Begin
		declare @body nvarchar(max)
		declare @subject nvarchar(100) =CONCAT('Auto Generate Names','-AVSSB')
		declare @body_format nvarchar(100)= 'HTML'
		declare @profilename nvarchar(100)='AVSSB-AutoGenerate'
		declare @datesmessage nvarchar(max)
		declare @query nvarchar(max)
		declare @querydb nvarchar(50) = 'TestDatabase'
		declare @attachment_name nvarchar(100) = CONCAT('AVSSB-AGN-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'.xls') -->Excel file
		declare @queryresultseperator nvarchar(50) = '	'
		declare @queryresultnopadding int = 1
		declare @tranRef# nvarchar(50)
		declare @gendercount int
		declare @gendercountm int
		declare @gendercountf int
		

		select @tranRef# = [AutoGenRefID] from [dbo].[AutoGeneratedAudit](nolock) where AGDID = @AuditRefID 

		IF(@gendr='M')
			BEGIN
				SELECT @gendercount = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where AuditRefID = @AuditRefID 
			END
		ELSE IF(@gendr='F')
			BEGIN
				SELECT @gendercount = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where AuditRefID = @AuditRefID 
			END
		ELSE
			BEGIN
				SELECT @gendercountm = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where gender='Male' and AuditRefID = @AuditRefID
				SELECT @gendercountf = COUNT(1) from [dbo].[AutoGeneratedNames](nolock) where gender='Female' and AuditRefID = @AuditRefID 
			END
		
		SET @query='SELECT RegNo ''Registration#'',last_name+'', ''+first_name ''User Name'',gender ''Gender'',email ''E-mail'',CONVERT(VARCHAR(20),phone) ''Phone'',Createdby ''Created By'',CONVERT(NVARCHAR(50),CreatedDate) ''Created Date'' from [dbo].[AutoGeneratedNames]'
		
		IF(@gendr='B')
			BEGIN
			SET @body = 'Dear User,
			<br><br>
			As requested, system has auto generated the names as per the inputs provided. Please find the transaction summary below.Please find the attachment for autogenerated results.
			<br><br>
			<strong>Transaction Summary</strong><br>
			----------------------------------<br>
			Execution Start -'+CONVERT(nvarchar(50),@exec_start)+'<br>
			<br>
			<strong>1.Auto Generated Names Summary<br></strong>
				     -> Total Rows(Names) created - '+convert(NVARCHAR(50),@counter)+'<br>
				     -> Transaction Type - Both(Male&Female) or Default Type<br>
				     -> Total Male Users - '+CONVERT(NVARCHAR(10),@gendercountm)+'.<br>
				     -> Total Female Users - '+CONVERT(NVARCHAR(10),@gendercountf)+'<br>
			<br>
			<strong>2.Transaction Reference# - '+@tranRef#+'<br></strong>
			<strong>3.Transaction Audit Reference# - '+@AuditRefID+'<br></strong>
			<strong>4.Transaction Status - '+@transtat+'<br></strong>
			<br>
			Execution End - '+CONVERT(NVARCHAR(50),@exec_end)+'<br>
			Total Execution Time - '+CONVERT(NVARCHAR(50),DATEDIFF(ms,@exec_start,@exec_end))+'millisecond(s)<br><br>
			Execution Status - Completed...<br>
			System Status - Ready...<br>
			<br>
			<strong>
			Regards,<br>
			AVSSB-AutoGenerate System<br>
			</strong>
			<hr>
			This is auto-generated mail. Replies to this mailbox are not monitored.<br>
			Responding Server - '+@@SERVERNAME
			END
		ELSE
			BEGIN
			SET @body = 'Dear User,
				<br><br>
				As requested, system has auto generated the names as per the inputs provided. Please find the transaction summary below.Please find the attachment for autogenerated results.
				<br><br>
				<strong>Transaction Summary</strong><br>
				----------------------------------<br>
				Execution Start -'+CONVERT(nvarchar(50),@exec_start)+'<br>
				<br>
				<strong>1.Auto Generated Names Summary<br></strong>
					-> Total Rows(Names) created - '+convert(nvarchar(50),@counter)+'<br>
					-> Transaction Type -'+@gender+'<br>
					-> Total Users('+@gender+') - '+CONVERT(NVARCHAR(10),@gendercount)+'.<br>
				<br>
				<strong>2.Transaction Reference# - '+@tranRef#+'<br></strong>
				<strong>3.Transaction Audit Reference# - '+@AuditRefID+'<br></strong>
				<strong>4.Transaction Status - '+@transtat+'<br></strong>
				<br>
				Execution End - '+CONVERT(nvarchar(50),@exec_end)+'<br>
				Total Execution Time - '+CONVERT(NVARCHAR(50),DATEDIFF(ms,@exec_start,@exec_end))+'millisecond(s)<br><br>
				Execution Status - Completed...<br>
				System Status - Ready...<br>
				<br>
				<strong>
				Regards,<br>
				AVSSB-AutoGenerate System<br>
				</strong>
				<hr>
				This is auto-generated mail. Replies to this mailbox are not monitored.<br>
				Responding Server - '+@@SERVERNAME
			END
		
		BEGIN
			BEGIN TRY
				EXEC msdb.dbo.sp_send_dbmail 
					@profile_name=@profilename,
					@recipients = @emailid,
					@body_format=@body_format,
					@body=@body,
					@query=@query,
					@execute_query_database = @querydb,
					@attach_query_result_as_file = 1,
					@query_attachment_filename=@attachment_name,
					@query_result_separator=@queryresultseperator,
					@query_result_no_padding=@queryresultnopadding,
					@subject=@subject,
					@importance = 'High',
					@sensitivity='Confidential',
					@query_result_header=1,
					@exclude_query_output =0

				PRINT 'Email sent to '+@emailid
			END TRY
			BEGIN CATCH
				PRINT 'Email Sending Failed'
			END CATCH
		END		
	END --> Send Email -End
END
GO
/****** Object:  StoredProcedure [dbo].[Create_Consignment_Booking]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 29, 2021
-- Description:	Creates Consignment Booking
-- =============================================
CREATE PROCEDURE [dbo].[Create_Consignment_Booking]
@consigneename nvarchar(100),
@consignername nvarchar(100),
@consigneeaddress nvarchar(100),
@consigneraddress nvarchar(100),
@tostateid nvarchar(100),
@circleid nvarchar(100),
@regionid nvarchar(100),
@divisionid nvarchar(100),
@districtid nvarchar(100),
@officeid nvarchar(100),
@officetypeid nvarchar(100),
@deliverytypeid nvarchar(100),
@destinationpincode int,
@createdby nvarchar(100)

AS
BEGIN --> SP Start
	SET NOCOUNT ON;

	Declare @bookingid nvarchar(100)
	Declare @ConsignmentBookingRefID nvarchar(100)
	Declare @createddate datetime
	Declare @errormessage nvarchar(100)
	Declare @destinationofficeId nvarchar(100)
	Declare @destaddress nvarchar(max)
	Declare @ConsignmentStatusID nvarchar(100)

	SET @bookingid = NEWID();
	SET @createddate = GETDATE();
	SET @ConsignmentBookingRefID = NEWID();
	SET @errormessage = 'Unable to create booking.'
	Select @destinationofficeId = OfficeID from Postal_Pincode_List Where OfficeId=@officeID
	Select @ConsignmentStatusID = ConsignmentStatusID from ConsignmentStatus Where ConsignmentStatusName='Received - Yet to Bag'

	--SET @destaddress = REPLACE(@consigneeaddress,',','<br/>')
	
	Begin Transaction
	Begin Try

	Insert Into [ConsignmentDetails]([ConsignmentBookingRefID],[BookingID],[BookingOfficeID],[DestinationOfficeID],[DestinationPincode],
	[CreatedBy],[CreatedOn],[ConsignmentStatusID],[StatusDate],[DestinationAddress])
	Values
	(@ConsignmentBookingRefID,@bookingid,@officeid,@destinationofficeId,@destinationpincode,@createdby,@createddate,@ConsignmentStatusID,@createddate,@consigneeaddress)

	INSERT INTO [ConsigneeDetails](ConsigneeDetailsID,BookingId,[ConsigneeName],[ConsignerName],[Active],[CreatedBy],[CreatedDate]) 
	VALUES(NEWID(),@bookingid,@consigneename,@consignername,1,@createdby,@createddate)

	Commit Transaction
	End Try

	Begin Catch
		SELECT @errormessage
		Rollback Transaction
	End Catch

	Select @bookingid

END --> SP End
GO
/****** Object:  StoredProcedure [dbo].[CreateandReplyMessages]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: Dec 16, 2020
-- Description:	Creates and Replies to Messages
-- =============================================
CREATE PROCEDURE [dbo].[CreateandReplyMessages]
@action nvarchar(100),
@messageid nvarchar(100),
@senderid nvarchar(100),
@receiverid nvarchar(100),
@subject nvarchar(100),
@message nvarchar(100),
@replyrequested bit,
@acknowledge bit,
@replymessage nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF(LTRIM(RTRIM(@action))='new') 
	BEGIN
		INSERT INTO [dbo].[Messages]
           ([MessageID]
           ,[SenderID]
           ,[ReceiverID]
           ,[MessageSubject]
           ,[Message]
           ,[ReplyRequired]
           ,[Acknowledged]
           ,[MessageParentID]
           ,[ReplyMessage]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[ModifiedBy]
           ,[ModifiedDate]
           ,[Active]
           ,[ReplyDate])
     VALUES
           (NEWID()
           ,@senderid
           ,@receiverid
           ,@subject
           ,@message
           ,@replyrequested
           ,NULL
           ,NULL
           ,NULL
           ,@senderid
           ,GETDATE()
           ,NULL
           ,NULL
           ,1
           ,NULL)

		SELECT 'Inserted' TranStatus
	END

		IF(LTRIM(RTRIM(@action))='reply') 
		BEGIN
			IF EXISTS(SELECT 1 FROM [Messages] Where MessageID=@messageid and ReplyRequired=1 and Active=1)
			BEGIN
				Update [Messages] SET ReplyMessage = @replymessage, ModifiedBy=@senderid, ModifiedDate=GETDATE(),ReplyRequired=0,
				ReplyDate = GETDATE(), Acknowledged=1
				Where MessageID = @messageid and Active=1

				SELECT 'Updated' TranStatus
			END
		END

		IF(LTRIM(RTRIM(@action))='acknowledge') 
		BEGIN
			IF EXISTS(SELECT 1 FROM [Messages] Where MessageID=@messageid and Active=1)
			BEGIN
				Update [Messages] SET ModifiedBy=@senderid, ModifiedDate=GETDATE(),ReplyDate = GETDATE(), Acknowledged=1
				Where MessageID = @messageid and Active=1

				SELECT 'Acknowledged' TranStatus
			END
		END
END
GO
/****** Object:  StoredProcedure [dbo].[DB_Mail_Trigger]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Sai Bhargav Abburu
-- Create date: Dec 05, 2020
-- Description:	Send Mail to Users
-- =============================================
CREATE PROCEDURE [dbo].[DB_Mail_Trigger]
@toaddress nvarchar(max),
@cc nvarchar(max),
@bcc nvarchar(max),
@subject nvarchar(200),
@bodyformat nvarchar(50),
@emailbody nvarchar(max),
@query nvarchar(max),
@querydatabase nvarchar(50),
@attachmentname nvarchar(50)

AS
BEGIN
	SET NOCOUNT ON;
	declare @profilename nvarchar(50)='AVSSB-AutoGenerate'
	declare @mailbody nvarchar(max)=@emailbody
	declare @queryresultseperator nvarchar(50)
	declare @queryresultnopadding int 
	declare @importance nvarchar(50) 
	declare @sensitivity nvarchar(50) 
	declare @attachqueryresult int
	

	IF(@query is not null)
	BEGIN
		SET @queryresultseperator = '	'
		SET @queryresultnopadding = 1
		SET @importance  = 'High'
		SET @sensitivity = 'Confidential'
		SET @attachqueryresult = 1
	END
	ELSE
	BEGIN
		SET @attachmentname = '';
		SET @query = '';
		SET @querydatabase = '';
		SET @queryresultseperator = ''
		SET @queryresultnopadding = 0
		SET @importance  = 'High'
		SET @sensitivity = 'Confidential'
		SET @attachqueryresult = 0
	END

	SET @toaddress = REPLACE(@toaddress,',',';')
	SET @cc = ISNULL(REPLACE(@cc,',',';'),'')
	SET @bcc = ISNULL(REPLACE(@bcc,',',';'),'')

	BEGIN
		BEGIN TRY
			EXEC msdb.dbo.sp_send_dbmail 
				@profile_name=@profilename,
				@recipients = @toaddress,
				@copy_recipients = @cc,
				@blind_copy_recipients = @bcc,
				@body_format=@bodyformat,
				@body=@mailbody,
				@query=@query,
				@execute_query_database = @querydatabase,
				@attach_query_result_as_file = @attachqueryresult,
				@query_attachment_filename=@attachmentname,
				@query_result_separator=@queryresultseperator,
				@query_result_no_padding=@queryresultnopadding,
				@subject=@subject,
				@exclude_query_output = 1,
				@importance = @importance,
				@sensitivity = @sensitivity

			PRINT 'Email Sent Successfully'
			PRINT 'To: '+@toaddress
			PRINT 'Cc: '+@cc
			PRINT 'Bcc: '+@bcc
		END TRY
		BEGIN CATCH
			PRINT 'Email Sending Failed'
		END CATCH
	END		
	SET NOCOUNT OFF;

END

GO
/****** Object:  StoredProcedure [dbo].[Download_AllUserList]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--> EXEC [Download_AllUserList] 'UR-AVS-M-937216'

CREATE PROCEDURE [dbo].[Download_AllUserList] @UserID nvarchar(100)
AS
BEGIN

SELECT [UserID] 'User ID'
      ,[first_name] 'First Name'
      ,[last_name] 'Last Name'
      ,[gender] 'Gender'
      ,[email] 'E-Mail'
      ,CASE WHEN [Active]=1 THEN 'Active' ELSE 'Inactive' END AS 'User Status'
      ,[CreatedBy] 'Created By'
      ,[CreatedDate] 'Created Date'
      ,[Phone] 'Phone'
  FROM [dbo].[Users]

END
GO
/****** Object:  StoredProcedure [dbo].[Generate_ASCII_ReferenceByOption]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================
-- Author:Sai Bhargav Abburu
-- Create date: Dec 23, 2020
-- Description:	Generates ASCII Character and Integers reference for password
--				and various purposes
-- EXEC [dbo].[Generate_ASCII_ReferenceByOption] 5
--Parameters: 
--1->Upper Case letters
--2-> Upper Case letters
--3-> Integers
--4-> Special Characters
--5-> All | This option is DEFAULT
-- =====================================================================================
CREATE PROCEDURE [dbo].[Generate_ASCII_ReferenceByOption] @type int
AS
BEGIN --> SP START
	SET NOCOUNT ON;
	
	Declare @startcount int
	Declare @endcount int
	Declare @int int
	Declare @char nvarchar(2)
	Declare @ascii int
	Declare @soundex int
	Declare @unicode int
	Declare @refchar nvarchar(2)
	Declare @refint int
	Declare @id nvarchar(50)

	--Initial SP settings.
	SET @startcount=NULL
	SET @endcount=NULL

	
	
	IF(@type=1) --> UPPER CASE LETTERS START
	BEGIN
	PRINT 'UPPER CASE LETTERS ASCII REFERENCE - START'
		SELECT @startcount = ASCII('A')
		SELECT @endcount = ASCII('Z')

		Delete from ASCII_Reference where ASCII_Code between @startcount and @endcount

		WHILE(@startcount<=@endcount)
		BEGIN
			SET @id = NEWID()
			SET @refchar = CHAR(@startcount)
			SET @ascii = ASCII(@refchar)
			SET @unicode = UNICODE(@refchar)

			INSERT INTO [dbo].[ASCII_Reference]
           ([ASCII_Ref_ID]
           ,[ASCII_Code]
           ,[Unicode_Code]
           ,[Ref_Char]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[ModifedBy]
           ,[ModifedDate])
			VALUES
           (@id,@ascii,@unicode,@refchar,'SYSTEM',GETDATE(),NULL,NULL)

		   SET @startcount = @startcount+1
		END
		PRINT 'UPPER CASE LETTERS ASCII REFERENCE - END'
	END--> UPPER CASE LETTERS END
	

	IF(@type=2) --> LOWER CASE LETTERS START
	BEGIN
	PRINT 'LOWER CASE LETTERS ASCII REFERENCE - START'
		Select @startcount = ASCII('a')
		Select @endcount = ASCII('z')

		Delete from ASCII_Reference where ASCII_Code between @startcount and @endcount

		WHILE(@startcount<=@endcount)
		BEGIN
			SET @id = NEWID()
			SET @refchar = CHAR(@startcount)
			SET @ascii = ASCII(@refchar)
			SET @unicode = UNICODE(@refchar)

			INSERT INTO [dbo].[ASCII_Reference]
           ([ASCII_Ref_ID]
           ,[ASCII_Code]
           ,[Unicode_Code]
           ,[Ref_Char]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[ModifedBy]
           ,[ModifedDate])
			VALUES
           (@id,@ascii,@unicode,@refchar,'SYSTEM',GETDATE(),NULL,NULL)

		   SET @startcount = @startcount+1
		END
		PRINT 'LOWER CASE LETTERS ASCII REFERENCE - END'
	END--> LOWER CASE LETTERS END
	

	IF(@type=3) --> INTEGERS START
	BEGIN
	PRINT 'INTEGERS ASCII REFERENCE - START'
		Select @startcount = ASCII(0)
		Select @endcount = ASCII(9)

		Delete from ASCII_Reference where ASCII_Code between @startcount and @endcount

		WHILE(@startcount<=@endcount)
		BEGIN
			SET @id = NEWID()
			SET @refint = CHAR(@startcount)
			SET @ascii = ASCII(@refint)
			SET @unicode = UNICODE(@refint)

			INSERT INTO [dbo].[ASCII_Reference]
           ([ASCII_Ref_ID]
           ,[ASCII_Code]
           ,[Unicode_Code]
           ,[Ref_Int]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[ModifedBy]
           ,[ModifedDate])
			VALUES
           (@id,@ascii,@unicode,@refint,'SYSTEM',GETDATE(),NULL,NULL)

		   SET @startcount = @startcount+1
		END
		PRINT 'INTEGERS ASCII REFERENCE - END'
	END --> INTEGERS END
	

	IF(@type=4) --> SPECIAL CHARACTERS START
	BEGIN
		EXEC [dbo].[GenerateASCII_ReferenceForSpecialChar]
	END --> SPECIAL CHARACTERS END

	IF(@type=5) --> DEFAULT ONE | --> ALL START
	BEGIN
		EXEC [dbo].[GenerateASCII_Reference_For_All]
	END  --> DEFAULT ONE | --> ALL END
	
	SET NOCOUNT OFF;

END -->SP END

GO
/****** Object:  StoredProcedure [dbo].[Generate_Initial_Credentials]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:Sai Bhargav Abburu
-- Create date: Dec 23, 2020
-- Description:	Credentials generator=> User name and Password
--
-- EXEC Generate_Initial_Credentials 'UR-AVS-F-100245'
-- ===============================================================
CREATE PROCEDURE [dbo].[Generate_Initial_Credentials] @RegNo NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @loginID nvarchar(10)
	Declare @pwd nvarchar(12)
	Declare @pwdchar char
	Declare @pwdint int
	Declare @runningcounter int
	Declare @maxcounter int
	Declare @ascii_ref int
	Declare @cred_id nvarchar(50) = NEWID();

	SET @runningcounter=0
	SET @maxcounter=12

	--> Generate LoginID details
	SELECT @loginID = CONCAT(LEFT(first_name,1),LEFT(last_name,1),RIGHT(RegNo,5)) from AutoGeneratedNames 
	where RegNo in (@RegNo)

	-->Generate Password
	WHILE(@runningcounter<=@maxcounter)
	BEGIN
		IF(LEN(ISNULL(@PWD,''))=@maxcounter)
		BREAK;

		Select @ascii_ref = CEILING(RAND()*(100+5)+5)

		IF NOT EXISTS(Select 1 from ASCII_Reference where ASCII_Code in (@ascii_ref) AND ASCII_Code NOT IN (32))
		BEGIN
			WHILE(1=1)
			BEGIN
				Select @ascii_ref = CEILING(RAND()*(100+5)+5)
				IF EXISTS(Select 1 from ASCII_Reference where ASCII_Code in (@ascii_ref) AND ASCII_Code NOT IN (32))
				BREAK;
				ELSE
				CONTINUE;
			END
		END

		IF(@ascii_ref BETWEEN 48 AND 57)
			BEGIN
				SELECT @pwdint = Ref_Int from ASCII_Reference where ASCII_Code=@ascii_ref
				SET @pwd = CONCAT(ISNULL(@pwd,''),CONVERT(NVARCHAR(2),@pwdint))
			END
		ELSE
			BEGIN
				SELECT @pwdchar = Ref_Char from ASCII_Reference where ASCII_Code=@ascii_ref
				SET @pwd = CONCAT(ISNULL(@pwd,''),@pwdchar)
			END
	
		SET @runningcounter = @runningcounter+1
	END

	--SELECT LTRIM(RTRIM(@loginID)),LTRIM(RTRIM(REPLACE(@pwd,'','Sp')))
	
	IF((SELECT ISNULL([Login_Cred_Ref_Num],'NULL') from AutoGeneratedNames where RegNo in (@RegNo) and Active=1) = 'NULL')
	BEGIN
		Update AutoGeneratedNames SET [Login_Cred_Ref_Num] = @cred_id where RegNo = @RegNo

		INSERT INTO [dbo].[Login_Credentials]([Credentials_Ref_ID],[LoginID],[Password],[CreatedBy],[CreatedDate])
		VALUES(@cred_id,@loginID,@pwd,'SYSTEM',GETDATE())
	END
	ELSE
	BEGIN
		Update Login_Credentials SET LoginID = @loginID,[Password]=@pwd,ModifiedBy='SYSTEM',ModifiedDate=GETDATE()
		where Credentials_Ref_ID in (Select [Login_Cred_Ref_Num] from AutoGeneratedNames where RegNo in (@RegNo))
	END	
END
GO
/****** Object:  StoredProcedure [dbo].[Generate_Upload_Transaction_Summary]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================================================
-- Author: Sai Bhargav Abburu
-- Create date: Mar 12, 2021
-- Description:	Generates Upload Transaction Summary before processing data

--> EXEC [dbo].[Generate_Upload_Transaction_Summary] 'e4dafc23-208f-4283-9e2e-f197994636d5','OfficeDetails'
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[Generate_Upload_Transaction_Summary] 
@StageTransactionID NVARCHAR(100),
@ReportType NVARCHAR(50)
AS
BEGIN --> SP Start
	SET NOCOUNT ON;

	IF NOT EXISTS(SELECT 1 FROM UploadTranSummary WHERE StageTranID = @StageTransactionID)
	BEGIN
		Declare @uploadby nvarchar(100)
		Declare @uploaddate datetime

		SELECT @uploadby = Uploadedby from UploadTransactionLog WHERE ServerTransactionID = @StageTransactionID
		SELECT @uploaddate = UploadedOn from UploadTransactionLog WHERE ServerTransactionID = @StageTransactionID

		IF(@ReportType = 'OfficeDetails')
			BEGIN
				Declare @StateChanges int
				Declare @CircleChanges int
				Declare @RegionChanges int
				Declare @DivisionChanges int
				Declare @DistrictChanges int
				Declare @OfficeNameChanges int
				Declare @OfficeTypeChanges int
				Declare @DeliveryChanges int
				Declare @PincodeChanges int

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn) 
				VALUES (NEWID(),@StageTransactionID, 'State',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn)  
				VALUES (NEWID(),@StageTransactionID, 'CircleName',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn) 
				VALUES (NEWID(),@StageTransactionID, 'RegionName',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn) 
				VALUES (NEWID(),@StageTransactionID, 'DivisionName',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn) 
				VALUES (NEWID(),@StageTransactionID, 'District',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn) 
				VALUES (NEWID(),@StageTransactionID, 'OfficeName',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn) 
				VALUES (NEWID(),@StageTransactionID, 'OfficeType',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn) 
				VALUES (NEWID(),@StageTransactionID, 'Delivery',@uploadby,@uploaddate)

				INSERT INTO UploadTranSummary([SummaryRefID],StageTranID,[Description],Uploadedby,UploadedOn)  
				VALUES (NEWID(),@StageTransactionID, 'Pincode',@uploadby,@uploaddate)

				SELECT @StateChanges =		COUNT(Distinct([State]))		FROM Postal_Data_Staging PDS WHERE [State]		NOT IN (SELECT StateName FROM Postal_State_List Where Active=1)	AND StageTransactionID=@StageTransactionID
				SELECT @CircleChanges =		COUNT(Distinct(CircleName))		FROM Postal_Data_Staging PDS WHERE CircleName	NOT IN (SELECT CircleName FROM Postal_Circle_List Where Active=1) AND StageTransactionID=@StageTransactionID
				SELECT @RegionChanges =		COUNT(Distinct(RegionName))		FROM Postal_Data_Staging PDS WHERE RegionName	NOT IN (SELECT RegionName FROM Postal_Region_List Where Active=1) AND StageTransactionID=@StageTransactionID
				SELECT @DivisionChanges =	COUNT(Distinct(DivisionName))	FROM Postal_Data_Staging PDS WHERE DivisionName	NOT IN (SELECT DivisionName FROM Postal_Division_List Where Active=1) AND StageTransactionID=@StageTransactionID
				SELECT @DistrictChanges =	COUNT(Distinct(District))		FROM Postal_Data_Staging PDS WHERE District 	NOT IN (SELECT DistrictName FROM Postal_District_List Where Active=1) AND StageTransactionID=@StageTransactionID
				SELECT @OfficeNameChanges = COUNT(Distinct(OfficeName))		FROM Postal_Data_Staging PDS WHERE OfficeName	NOT IN (SELECT OfficeName FROM Postal_Office_List Where Active=1) AND StageTransactionID=@StageTransactionID
				SELECT @OfficeTypeChanges =	COUNT(Distinct(OfficeType))		FROM Postal_Data_Staging PDS WHERE OfficeType	NOT IN (SELECT OfficeTypeCode FROM Postal_Office_Type Where Active=1) AND StageTransactionID=@StageTransactionID
				SELECT @DeliveryChanges =	COUNT(Distinct(Delivery))		FROM Postal_Data_Staging PDS WHERE Delivery		NOT IN (SELECT DeliveryType FROM Postal_Delivery_Type Where Active=1) AND StageTransactionID=@StageTransactionID
				SELECT @PincodeChanges =	COUNT(Distinct(Pincode))		FROM Postal_Data_Staging PDS WHERE Pincode		NOT IN (SELECT Pincode FROM Postal_Pincode_List Where Active=1) AND StageTransactionID=@StageTransactionID

				Update UploadTranSummary SET CountOfChanges = @StateChanges		WHERE [Description]='State'
				Update UploadTranSummary SET CountOfChanges = @CircleChanges		WHERE [Description]='CircleName'
				Update UploadTranSummary SET CountOfChanges = @RegionChanges		WHERE [Description]='RegionName'
				Update UploadTranSummary SET CountOfChanges = @DivisionChanges		WHERE [Description]='DivisionName'
				Update UploadTranSummary SET CountOfChanges = @DistrictChanges		WHERE [Description]='District'
				Update UploadTranSummary SET CountOfChanges = @OfficeNameChanges	WHERE [Description]='OfficeName'
				Update UploadTranSummary SET CountOfChanges = @OfficeTypeChanges	WHERE [Description]='OfficeType'
				Update UploadTranSummary SET CountOfChanges = @DeliveryChanges		WHERE [Description]='Delivery'
				Update UploadTranSummary SET CountOfChanges = @PincodeChanges		WHERE [Description]='Pincode'

			END
	END
	
	SELECT * FROM UploadTranSummary
END --> SP End
GO
/****** Object:  StoredProcedure [dbo].[GenerateASCII_Reference_For_All]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Sai Bhargav Abburu
-- Create date: Dec 23, 2020 
-- Description:	Generates ASCII reference codes.
--
-- EXEC [dbo].[GenerateASCII_Reference_For_All]
-- =============================================
CREATE PROCEDURE [dbo].[GenerateASCII_Reference_For_All]
AS
BEGIN
	SET NOCOUNT ON;
	
	EXEC [dbo].[Generate_ASCII_ReferenceByOption] 1
	EXEC [dbo].[Generate_ASCII_ReferenceByOption] 2
	EXEC [dbo].[Generate_ASCII_ReferenceByOption] 3
	EXEC [dbo].[Generate_ASCII_ReferenceByOption] 4

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[GenerateASCII_ReferenceForSpecialChar]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Author:Sai Bhargav Abburu
-- Create date: Dec 23, 2020
-- Description:	Generates ASCII reference codes for special characters.
--
-- EXEC [dbo].[GenerateASCII_ReferenceForSpecialChar]
-- =======================================================================
CREATE PROCEDURE [dbo].[GenerateASCII_ReferenceForSpecialChar]
AS
BEGIN --> SP START
	SET NOCOUNT ON;
	
	Declare @startcount int
	Declare @endcount int
	Declare @int int
	Declare @char nvarchar(2)
	Declare @ascii int
	Declare @unicode int
	Declare @refchar nvarchar(2)
	Declare @refint int
	Declare @id nvarchar(50)

	--Initial SP settings.
	SET @startcount=NULL
	SET @endcount=NULL

	BEGIN -->Batch 1 START
	PRINT 'BATCH 1 - START'
		SET @startcount = 32
		SET @endcount = 47

		Delete from ASCII_Reference where ASCII_Code between @startcount and @endcount

		WHILE(@startcount<=@endcount)
		BEGIN
			SET @id = NEWID()
			SET @refchar = CHAR(@startcount)
			SET @ascii = ASCII(@refchar)
			SET @unicode = UNICODE(@refchar)

			INSERT INTO [dbo].[ASCII_Reference]
			([ASCII_Ref_ID]
			,[ASCII_Code]
			,[Unicode_Code]
			,[Ref_Char]
			,[CreatedBy]
			,[CreatedDate]
			,[ModifedBy]
			,[ModifedDate])
			VALUES
			(@id,@ascii,@unicode,@refchar,'SYSTEM',GETDATE(),NULL,NULL)

			SET @startcount = @startcount+1
		END
		PRINT 'BATCH 1 - END'
	END -->Batch 1 END
	

	BEGIN -->Batch 2 START
	PRINT 'BATCH 2 - START'
		SET @startcount = 58
		SET @endcount = 64

		Delete from ASCII_Reference where ASCII_Code between @startcount and @endcount

		WHILE(@startcount<=@endcount)
		BEGIN
			SET @id = NEWID()
			SET @refchar = CHAR(@startcount)
			SET @ascii = ASCII(@refchar)
			SET @unicode = UNICODE(@refchar)

			INSERT INTO [dbo].[ASCII_Reference]
			([ASCII_Ref_ID]
			,[ASCII_Code]
			,[Unicode_Code]
			,[Ref_Char]
			,[CreatedBy]
			,[CreatedDate]
			,[ModifedBy]
			,[ModifedDate])
			VALUES
			(@id,@ascii,@unicode,@refchar,'SYSTEM',GETDATE(),NULL,NULL)

			SET @startcount = @startcount+1
		END
		PRINT 'BATCH 2 - END'
	END -->Batch 2 END
	

	BEGIN -->Batch 3 START
	PRINT 'BATCH 3 - START'
		SET @startcount = 91
		SET @endcount = 96

		Delete from ASCII_Reference where ASCII_Code between @startcount and @endcount

		WHILE(@startcount<=@endcount)
		BEGIN
			SET @id = NEWID()
			SET @refchar = CHAR(@startcount)
			SET @ascii = ASCII(@refchar)
			SET @unicode = UNICODE(@refchar)

			INSERT INTO [dbo].[ASCII_Reference]
			([ASCII_Ref_ID]
			,[ASCII_Code]
			,[Unicode_Code]
			,[Ref_Char]
			,[CreatedBy]
			,[CreatedDate]
			,[ModifedBy]
			,[ModifedDate])
			VALUES
			(@id,@ascii,@unicode,@refchar,'SYSTEM',GETDATE(),NULL,NULL)

			SET @startcount = @startcount+1
		END
		PRINT 'BATCH 3 - END'
	END -->Batch 3 END
	

	BEGIN -->Batch 4 START
	PRINT 'BATCH 4 - START'
		SET @startcount = 123
		SET @endcount = 126

		Delete from ASCII_Reference where ASCII_Code between @startcount and @endcount

		WHILE(@startcount<=@endcount)
		BEGIN
			SET @id = NEWID()
			SET @refchar = CHAR(@startcount)
			SET @ascii = ASCII(@refchar)
			SET @unicode = UNICODE(@refchar)

			INSERT INTO [dbo].[ASCII_Reference]
			([ASCII_Ref_ID]
			,[ASCII_Code]
			,[Unicode_Code]
			,[Ref_Char]
			,[CreatedBy]
			,[CreatedDate]
			,[ModifedBy]
			,[ModifedDate])
			VALUES
			(@id,@ascii,@unicode,@refchar,'SYSTEM',GETDATE(),NULL,NULL)

			SET @startcount = @startcount+1
		END
		PRINT 'BATCH 4 - END'
	END -->Batch 4 END
	
	SET NOCOUNT OFF;

END -->SP END
GO
/****** Object:  StoredProcedure [dbo].[GenerateDatesBetweenRange]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:		Sai Bhargav Abburu	
-- Create date: Dec 05, 2020
-- Description:	Generate Dates between given range.
--
-- EXEC [dbo].[GenerateDatesBetweenRange] '2020-10-01','2021-10-15','AVSSB-AUDIT-D89CC'
-- =====================================================
CREATE PROCEDURE [dbo].[GenerateDatesBetweenRange] @date_from date, @date_to date,@AutoGenID NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @counter int
	declare @maxcounter int

	select @maxcounter = DATEDIFF(DD,@date_from,@date_to)
	--select @maxcounter
	SET @counter=0

	BEGIN
		BEGIN TRANSACTION
			BEGIN TRY
				WHILE (@counter <= @maxcounter)
					BEGIN
						declare @refdate date 
						declare @DateId nvarchar(50) = newid()
						declare @Date nvarchar(50)
						declare @month nvarchar(50)
						declare @year nvarchar(50)
						declare @day nvarchar(50)
						declare @week nvarchar(50)
						SET @refdate = CAST(DATEADD(dd,@counter,@date_from)as DATE)
						--select @counter
							IF(@refdate <= @date_to)
								BEGIN
									set @Date = CONVERT(nvarchar(10),DATEPART(dd,@refdate))
									set @month = CONVERT(nvarchar(10),DATEPART(mm,@refdate))
									set @year = CONVERT(nvarchar(10),DATEPART(yy,@refdate))
									set @day = CONVERT(nvarchar(20),DATENAME(WEEKDAY,@refdate))
									set @week = CONVERT(nvarchar(10),DATEPART(WEEK,@refdate))
		
									Insert into [dbo].[AutoGeneratedDates]([DateID],[Date],[Month],[Year],[Day],[FullDate],[WeekNo],[Active],[GeneratedBy],[GeneratedDate],[AuditRefID])
									Values
									(@DateId,@Date,@month, @year,@day,@refdate,@week,1,'SYSTEM',GETDATE(),@AutoGenID)
									--select @DateId,@Date,@month, @year,@day,@refdate,@week,1,'SYSTEM',GETDATE()
								END
								SET @counter = @counter+1 --> Counter Increment
							
						--select @refdate
					END
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
			END CATCH
	END
END
SET NOCOUNT OFF;
GO
/****** Object:  StoredProcedure [dbo].[GenerateEMI]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: SAI BHARGAV ABBURU
-- Create date: DEC 05, 2020
-- Description:	Generate EMI Schedule post Loan Approval
--
-- EXEC GENERATEEMI 'AVSSB-LOAN-20201130-54AF1','ibhargav547@gmail.com'
-- =============================================
CREATE PROCEDURE [dbo].[GenerateEMI]
@LoanID NVARCHAR(50),@email nvarchar(100)
AS
BEGIN --> SP START
	SET NOCOUNT ON;

	DECLARE @PRINCIPLE DECIMAL(16,2)
	DECLARE @INTERESTRATE DECIMAL(16,2)
	DECLARE @TENURE INT
	DECLARE @PROCESSINGCHARGE DECIMAL(16,2)
	DECLARE @GST DECIMAL(16,2)
	DECLARE @PERMONTHEMI DECIMAL(16,2)
	DECLARE @TOTALPAYABLE DECIMAL(16,2)
	DECLARE @TOTALPAYPERMONTH DECIMAL(16,2)
	DECLARE @TOTALEMICOUNTER INT
	DECLARE @RUNNINGCOUNTER INT
	DECLARE @INTERESTPERMONTH DECIMAL(16,2)
	DECLARE @PRICIPLEPERMONTH DECIMAL(16,2)
	DECLARE @CYCLEDATE DATETIME -->CYCLE DATE
	DECLARE @REPAYDATE DATETIME -->REPAY DATE
	DECLARE @TYPE NVARCHAR(50) 
	DECLARE @TOTALTENURE INT
	DECLARE @EMIREFID NVARCHAR(50)
	DECLARE @LOANREFID NVARCHAR(50)
	DECLARE @PROCESSCHGAMT DECIMAL(16,2)
	DECLARE @GSTAMT DECIMAL(16,2)
	DECLARE @AMTNOCHARGE DECIMAL(16,2)
	DECLARE @GSTPMAMT DECIMAL(16,2)
	DECLARE @AMTNOPMCHARGE DECIMAL(16,2)


	IF EXISTS (SELECT 1 FROM LoanDetails WHERE LoanID=@LoanID AND [Status]='APPROVED')
	BEGIN -->
		EXEC [dbo].[RecordTranSummary] @LoanID,'[dbo].[EmiTable]','EMI Generate','Received'

		Create Table #tempemi(EmiRefID nvarchar(50),LoanID nvarchar(50),PrincipleAmt int, InterestAmt int,totalpay int,CycleDate datetime, RepayDate datetime,Create_dt datetime)

		-->Initial SP Settings
		SET @TOTALEMICOUNTER=0
		SET @RUNNINGCOUNTER=1
		SET @PRINCIPLE=0.00
		SET @INTERESTRATE=0.00
		SET @TENURE=0
		SET @TOTALPAYABLE = 0
		SET @PROCESSINGCHARGE = 0.02 --> 15% OF TOTALPAYABLE AS PROCESSING AMOUNT
		SET @GST = 0.18 --> 18% OF TOTALPAYABLE AS PROCESSING AMOUNT
		SELECT @TYPE = [TYPE] FROM LoanDetails WHERE LoanID=@LoanID
		SELECT @LOANREFID = LoanRefID FROM LoanDetails WHERE LoanID=@LoanID

		EXEC [dbo].[RecordTranSummary] @LoanID,'[dbo].[EmiTable]','EMI Generate','Started'
		EXEC [dbo].[RecordTranSummary] @LoanID,'[dbo].[EmiTable]','EMI Generate','Processing'

		IF(@TYPE='Yearly')
		BEGIN -->YEARLY IF START
			SELECT @TENURE = (TENURE*12) FROM LoanDetails WHERE LoanID=@LoanID
			
			SET @TOTALTENURE = @TENURE -->YEARS CONVERT TO MONTHS
			SET @TOTALEMICOUNTER = @TOTALTENURE -->COUNTER SETTINGS FOR ENTIRE EMI

			SELECT @PRINCIPLE = PrincipleAmount FROM LoanDetails WHERE LoanID=@LoanID
			SELECT @INTERESTRATE = InterestPercent FROM LoanDetails WHERE LoanID=@LoanID
			
			-->SCALAR-VALUED FUNCTION RETURNS PER MONTH EMI AMOUNT
			SELECT @INTERESTPERMONTH = [dbo].[UDF_SimpleIntEMIAmount] ('Y',@PRINCIPLE,@INTERESTRATE,@TENURE) 

			SET @PRICIPLEPERMONTH = @PRINCIPLE/@TOTALEMICOUNTER

			SET @AMTNOCHARGE = @PRINCIPLE+(@INTERESTPERMONTH*@TENURE)
			SET @PROCESSCHGAMT = @AMTNOCHARGE*@PROCESSINGCHARGE
			SET @GSTAMT = @AMTNOCHARGE*@GST
			SET @TOTALPAYABLE = @AMTNOCHARGE+@PROCESSCHGAMT+@GSTAMT --> TOTAL REPAY AMOUNT

			UPDATE LoanDetails SET BalancePayable = @TOTALPAYABLE,BalPrinciple = @PRINCIPLE,BalInterest = (@INTERESTPERMONTH*@TOTALEMICOUNTER),ProcessingAmt=@PROCESSCHGAMT
			WHERE LoanID=@LoanID

			WHILE(@TOTALEMICOUNTER >= @RUNNINGCOUNTER)
			BEGIN --> EMI WHILE START
				IF(@RUNNINGCOUNTER=1)
				BEGIN
					SELECT @CYCLEDATE = DATEADD(MM,1,ApprovedDate) FROM LoanDetails WHERE LoanID=@LoanID
					SELECT @REPAYDATE = DATEADD(DD,20,@CYCLEDATE)
					SET @EMIREFID = CONVERT(NVARCHAR(100),CONCAT(REPLACE(@LOANID,'-','/'),'/EMI/RP',
									IIF(LEN(@RUNNINGCOUNTER)>1,CONVERT(NVARCHAR(5),@RUNNINGCOUNTER),CONCAT('0',CONVERT(NVARCHAR(5),@RUNNINGCOUNTER)))))
				END
				ELSE
				BEGIN
					SELECT @CYCLEDATE = DATEADD(DD,10,MAX(RepayDate))	FROM #tempemi WHERE LoanID=@LoanID --ORDER BY Create_dt DESC 
					SELECT @REPAYDATE = DATEADD(DD,20,@CYCLEDATE)
					SET @EMIREFID = CONVERT(NVARCHAR(100),CONCAT(REPLACE(@LOANID,'-','/'),'/EMI/RP',
										IIF(LEN(@RUNNINGCOUNTER)>1,CONVERT(NVARCHAR(5),@RUNNINGCOUNTER),CONCAT('0',CONVERT(NVARCHAR(5),@RUNNINGCOUNTER)))))
				END

					SET @AMTNOPMCHARGE = @PRICIPLEPERMONTH+@INTERESTPERMONTH+(@PROCESSCHGAMT/@TOTALEMICOUNTER)
					SET @GSTPMAMT = @AMTNOPMCHARGE*@GST
					SET @TOTALPAYPERMONTH = @AMTNOPMCHARGE+@GSTPMAMT
				
				

				--UPDATE LoanDetails SET BalancePayable = (BalancePayable-@TOTALPAYPERMONTH) WHERE LoanID=@LoanID
				--UPDATE LoanDetails SET BalPrinciple = (BalPrinciple-@PRICIPLEPERMONTH) WHERE LoanID=@LoanID
				--UPDATE LoanDetails SET BalInterest = (BalInterest-@INTERESTPERMONTH) WHERE LoanID=@LoanID

				INSERT INTO #tempemi(EmiRefID,LoanID,PrincipleAmt,InterestAmt,totalpay,CycleDate,RepayDate,Create_dt)
				VALUES(@EMIREFID,@LoanID,@PRICIPLEPERMONTH,@INTERESTPERMONTH,@TOTALPAYPERMONTH,@CYCLEDATE,@REPAYDATE,GETDATE())

				SET @RUNNINGCOUNTER = @RUNNINGCOUNTER+1	
			END --> EMI WHILE END
		END --> YEARLY IF END
		INSERT INTO [dbo].[EmiTable]([EmiRefID],[LoanRefID],[LoanID],[CycleDate],[RepaymentDate],[PrincipleAmount],[InterestAmount],[TotalPayable])
		SELECT EmiRefID,@LOANREFID,@LoanID,CycleDate,RepayDate,PrincipleAmt,InterestAmt,totalpay FROM #tempemi
		--SELECT SUM(PrincipleAmt),SUM(InterestAmt),SUM(totalpay) FROM #tempemi

		UPDATE EmiTable SET
		[Month]=CONCAT(DATEPART(MM,RepaymentDate),'/',DATEPART(YYYY,RepaymentDate)),
		Paid=0,
		Active=1,
		CreatedBy='SYSTEM',
		CreateadDate=GETDATE() where LoanID=@LoanID

		EXEC [dbo].[RecordTranSummary] @LoanID,'[dbo].[EmiTable]','EMI Generate','Completed'
	END
	SELECT * FROM EmiTable WHERE LoanID=@LoanID order by RepaymentDate --> FINAL RESULTS

	BEGIN --> Send Email Begin
		declare @body nvarchar(max)
		declare @subject nvarchar(100) =CONCAT('Genarate Loan Details','-AVSSB')
		declare @body_format nvarchar(100)= 'HTML'
		declare @profilename nvarchar(100)='AVSSB-AutoGenerate'
		declare @query nvarchar(max)
		declare @querydb nvarchar(50) = DB_NAME()
		declare @attachment_name nvarchar(100) = CONCAT('AVSSB-LOAN-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'.txt') -->Text file
		declare @queryresultseperator nvarchar(50) = '	'
		declare @queryresultnopadding int = 1

		SET @query = 'select UserID ''User ID'',
						LoanRefID ''Loan Reference#'',
						LoanID ''Loan ID'',
						PrincipleAmount ''Requested Amount'',
						[Type] ''Loan Type'',
						Tenure ''Tenure'',
						InterestPercent ''Interest Rate''
						from LoanDetails where LoanID='+@loanid

		SET @body = 'Dear User,<br>
		<br>
		As requested, system has successfully generated your loan details for requested amount. Please note, upon successful approval of loan for requested amount,
		processing charges of INR 199.00+GST(18% of approved amount) will be added to the total loan amount along with interest. Please find the attachment for further details.
		Please feel free to call to our customer care for any information or to know about our latest offers on 1800-209-1568/1800-457-8965.<br>
		<br>
		Regards,
		AVSSB-LoanGenerate<br>
		<hr>
		This is an autogenerated e-mail. Please do not reply. Replies to this mailbox are not monitored.<br>
		Please send your queries <a href="mailto:maseratibhargav@outlook.com">here</a>.Please quote your LoanID for future communications.<br>
		Responding Server-'+@@SERVERNAME

		
			EXEC [dbo].[DB_Mail_Trigger]
			@toaddress = @email,
			@cc = NULL,
			@bcc = NULL,
			@subject = @subject,
			@bodyformat = @body_format,
			@emailbody = @body,
			@query = @query,
			@querydatabase = @querydb,
			@attachmentname = @attachment_name

	END --> Send Email End

	DROP TABLE #tempemi
	SET NOCOUNT OFF;
END -->SP END
GO
/****** Object:  StoredProcedure [dbo].[GenerateLoanDetails]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===================================================================================================
-- Author:		Sai Bhargav Abburu
-- Create date: Nov 29, 2020
-- Description:	This SP will generate loan details for customer
--
-- EXEC [dbo].[GenerateLoanDetails] 'UR-AVS-F-100069',100000,20.00,1,'year','ibhargav547@gmail.com'
-- ===================================================================================================
CREATE PROCEDURE [dbo].[GenerateLoanDetails]
@UserID nvarchar(50),
@principleamount int,
@interest int,
@tenure int,
@tenuretype nvarchar(50),
@email nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	declare @interestamt int
	declare @tenuredur int
	declare @generatedate datetime
	declare @loanrefid nvarchar(50)
	declare @loanid nvarchar(50)
	declare @intramtpercent int
	declare	@intpercent decimal(16,2)
	
	IF EXISTS(Select 1 from Users where UserID=@UserID and Active=1)
	BEGIN
		IF(@tenuretype='year')
		BEGIN
			SET @tenuretype='Yearly'
			SET @generatedate = GETDATE()
			SET @tenuredur = @tenure
			SET @intpercent = @interest
			SET @interestamt = (@principleamount*(@interest/100))*@tenuredur
			SET @loanrefid = NEWID()
			SET @loanid = CONCAT('AVSSB-LOAN-',DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-',RIGHT(@loanrefid,5))

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Started'

			Insert Into [dbo].[LoanDetails]([LoanRefID],[UserID],[LoanID],[PrincipleAmount],[Type],[Interest],[Tenure],[Active],
			[Status],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[InterestPercent])Values
			(@loanrefid,@UserID,@loanid,@principleamount,@tenuretype,@interestamt,@tenure,0,'Open','SYSTEM',GETDATE(),NULL,NULL,@intpercent)

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Completed'
		END
		IF(@tenuretype='month')
		BEGIN
			SET @tenuretype='Monthly'
			SET @generatedate = GETDATE()
			SET @tenuredur = @tenure
			SET @intpercent = CONCAT(CONVERT(NVARCHAR(50),@interest),'%')
			SET @interestamt = (@principleamount*(@interest/100))
			SET @interestamt = @interestamt/12
			SET @interestamt = @interestamt*@tenuredur
			SET @loanrefid = NEWID()
			SET @loanid = CONCAT('AVSSB-LOAN-',DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-',RIGHT(@loanrefid,5))

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Started'

			Insert Into [dbo].[LoanDetails]([LoanRefID],[UserID],[LoanID],[PrincipleAmount],[Type],[Interest],[Tenure],[Active],
			[Status],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[InterestPercent])Values
			(@loanrefid,@UserID,@loanid,@principleamount,@tenuretype,@interestamt,@tenure,0,'Open','SYSTEM',GETDATE(),NULL,NULL,@intpercent)

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Completed'
		END
		IF(@tenuretype='week')
		BEGIN
			SET @tenuretype='Weekly'
			SET @generatedate = GETDATE()
			SET @tenuredur = @tenure
			SET @intpercent = CONCAT(CONVERT(NVARCHAR(50),@interest),'%')
			SET @interestamt = (@principleamount*(@interest/100))
			SET @interestamt = @interestamt/365
			SET @interestamt = @interestamt*(@tenuredur*7)
			SET @loanrefid = NEWID()
			SET @loanid = CONCAT('AVSSB-LOAN-',DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-',RIGHT(@loanrefid,5))

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Started'

			Insert Into [dbo].[LoanDetails]([LoanRefID],[UserID],[LoanID],[PrincipleAmount],[Type],[Interest],[Tenure],[Active],
			[Status],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[InterestPercent])Values
			(@loanrefid,@UserID,@loanid,@principleamount,@tenuretype,@interestamt,@tenure,0,'Open','SYSTEM',GETDATE(),NULL,NULL,@intpercent)

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Completed'
		END
		IF(@tenuretype='days')
		BEGIN
			SET @tenuretype='Days'
			SET @generatedate = GETDATE()
			SET @tenuredur = @tenure
			SET @intpercent = CONCAT(CONVERT(NVARCHAR(50),@interest),'%')
			SET @interestamt = (@principleamount*(@interest/100))
			SET @interestamt = @interestamt/365
			SET @interestamt = @interestamt*@tenuredur
			SET @loanrefid = NEWID()
			SET @loanid = CONCAT('AVSSB-LOAN-',DATEPART(YYYY,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(DD,GETDATE()),'-',RIGHT(@loanrefid,5))

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Started'

			Insert Into [dbo].[LoanDetails]([LoanRefID],[UserID],[LoanID],[PrincipleAmount],[Type],[Interest],[Tenure],[Active],
			[Status],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[InterestPercent])Values
			(@loanrefid,@UserID,@loanid,@principleamount,@tenuretype,@interestamt,@tenure,0,'Open','SYSTEM',GETDATE(),NULL,NULL,@intpercent)

			EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Completed'
		END
		EXEC [dbo].[RecordTranSummary] @loanid,'[dbo].[LoanDetails]','Loan Details Generation','Pending Approval'

		Update LoanDetails SET BalancePayable=PrincipleAmount+Interest,
		BalPrinciple=PrincipleAmount,
		BalInterest=Interest,
		[Status]='Pending Approval',
		ModifiedBy='SYSTEM',
		ModifiedDate=GETDATE() 
		where LoanRefID=@loanrefid	
	END

	BEGIN --> Send Email Begin
		declare @body nvarchar(max)
		declare @subject nvarchar(100) =CONCAT('Generate Loan Details','-AVSSB')
		declare @body_format nvarchar(100)= 'HTML'
		declare @query nvarchar(max)
		declare @querydb nvarchar(50) = DB_NAME()
		declare @queryresultseperator nvarchar(50) = '	'
		declare @queryresultnopadding int = 1
		declare @attachment_name nvarchar(100) = CONCAT('AVSSB-LOAN-',DATEPART(DD,GETDATE()),DATEPART(MM,GETDATE()),DATEPART(YY,GETDATE()),'.xls') -->Excel file

		SELECT * into #temp from LoanDetails where LoanID=@loanid

		--SET @query = 'select UserID ''User ID'',
		--				LoanRefID ''Loan Reference#'',
		--				LoanID ''Loan ID'',
		--				PrincipleAmount ''Requested Amount'',
		--				[Type] ''Loan Type'',
		--				Tenure ''Tenure'',
		--				InterestPercent ''Interest Rate''
		--				from LoanDetails where LoanRefID ='+CONVERT(NVARCHAR(50),@loanrefid)+''


		SET @body = '<strong>Dear User,</strong><br>
		<br>
		As requested, system has successfully generated your loan details for requested amount. Please note, upon successful approval of loan for requested amount,
		processing charges of INR 199.00+GST(18% of approved amount) will be added to the total loan amount along with interest. Please find the attachment for
		further details.Please feel free to call to our customer care for any information or to know about our latest offers on 1800-209-1568 (or) 1800-457-8965.<br>
		<br>
		<strong><u>Loan Details:</u></strong><br>
		<ul>
			<li>Loan Reference# - '+@loanrefid+'</li>
			<li>Loan ID - '+@loanid+'</li>
			<li>Requested Amount - INR '+CONVERT(nvarchar(50),@principleamount)+'</li>
			<li>Tenure - '+IIF(LEN(@TENURE)>1,CONVERT(nvarchar(50),@tenure),CONCAT('0',CONVERT(nvarchar(50),@tenure)))+'</li>
			<li>Tenure Type - '+CONVERT(nvarchar(50),UPPER(@tenuretype))+'</li>
			<li>Interest Rate - '+CONVERT(nvarchar(50),@intpercent)+'%</li>
			
		</ul><br>
		<i>Please send your queries <a href="mailto:maseratibhargav@outlook.com?cc=ibhargav547@gmail.com">here</a>.
		Please refer LoanID in subject for future communications if any.</i><br>
		<br>
		<strong>
			Best Regards,<br>
			AVSSB-Loan Generate
		</strong>
		<br>
		<hr>
		<i>This is an autogenerated e-mail. Please do not reply. Replies to this mailbox are not monitored.<br>
		Responding Server-'+@@SERVERNAME+'</i>'

		
			--EXEC [dbo].[DB_Mail_Trigger]
			--@toaddress = @email,
			--@cc = NULL,
			--@bcc = NULL,
			--@subject = @subject,
			--@bodyformat = @body_format,
			--@emailbody = @body,
			--@query = NULL,
			--@querydatabase = NULL,
			--@attachmentname = @attachment_name

			EXEC msdb.dbo.sp_send_dbmail 
				@profile_name='AVSSB-AutoGenerate',
				@recipients = @email,
				@body_format=@body_format,
				@body=@body,
				@subject=@subject,
				@importance = 'High'
				--@query=@query,
				--@execute_query_database = @querydb,
				--@attach_query_result_as_file = 1,
				--@query_attachment_filename=@attachment_name,
				--@query_result_separator=@queryresultseperator,
				--@query_result_no_padding=@queryresultnopadding
				--@exclude_query_output = 1
				

	END --> Send Email End
END
--DROP TABLE #temp
SET NOCOUNT OFF;
GO
/****** Object:  StoredProcedure [dbo].[Get_Consignment_Details_By_BookingID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 29, 2021
-- Description:	Get_Consignment_Details_By_BookingID
--> EXEC [dbo].[Get_Consignment_Details_By_BookingID] 'C1D7C005-395A-4356-8B4C-8A27BFE8C5C2'
-- =========================================================================================
CREATE PROCEDURE [dbo].[Get_Consignment_Details_By_BookingID] 
@BookingID Nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	Select Distinct 
	CED.BookingID ,CED.ConsigneeName ,CED.ConsignerName ,CTD.DestinationAddress,PSL.StateName ,
	PCL.CircleName ,PRL.RegionName ,PDvL.DivisionName ,PDL.DistrictName ,
	POL.OfficeName,Pin.Pincode 
	From ConsigneeDetails CED
	Inner Join ConsignmentDetails CTD on CED.BookingID = CTD.BookingID
	Inner Join Postal_Pincode_List Pin on Pin.Pincode = CTD.DestinationPincode
	Inner Join Postal_Office_List POL on POL.OfficeID = CTD.DestinationOfficeID
	Inner Join Postal_District_List PDL on POL.DistrictID = PDL.DistrictID
	Inner Join Postal_Division_List PDvL on PDvL.DivisionID = PDL.DivisionID
	Inner Join Postal_Region_List PRL on PRL.RegionID = PDvL.RegionID
	Inner Join Postal_Circle_List PCL on PCL.CircleID = PRL.CircleID
	Inner Join  Postal_State_List PSL on PSL.StateID = PCL.StateID
	Where 
	CED.BookingID = @BookingID and
	Pin.Active=1 and POL.Active=1 and PDL.Active=1 and PDvL.Active=1 
	and PRL.Active=1 and PCL.Active=1 and PSL.Active=1
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Consignment_History]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu 
-- Create date: May 15, 2021
-- Description:Fetches Consignment History

--> EXEC [Get_Consignment_History] '7A965ABF-3B83-4964-A681-862A251F4643'
-- =============================================
CREATE PROCEDURE [dbo].[Get_Consignment_History] @BookingID nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT CTD.BookingID, CTD.DestinationPincode, CS.ConsignmentStatusName, TC.StatusDateTime, TC.SortOrder
	FROM ConsignmentDetails CTD
	Inner Join TrackConsignment TC on TC.BookingID = CTD.BookingID
	Inner Join ConsignmentStatus CS on TC.ConsignmentStatusID = CS.ConsignmentStatusID
	Where CTD.BookingID = @BookingID
	Order By TC.SortOrder ASC

END
GO
/****** Object:  StoredProcedure [dbo].[Get_Consignment_Status_By_BookingID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Apr 16, 2021
-- Description:	Get_Consignment_Status_By_BookingID
--> EXEC [dbo].[Get_Consignment_Status_By_BookingID] '26408291-7C47-435C-A77E-33484193D3B7'
-- =========================================================================================
CREATE PROCEDURE [dbo].[Get_Consignment_Status_By_BookingID] 
@BookingID Nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	Select Distinct 
	CED.BookingID ,CED.ConsigneeName ,CED.ConsignerName ,CTD.DestinationAddress,PSL.StateName ,
	PCL.CircleName ,PRL.RegionName ,PDvL.DivisionName ,PDL.DistrictName ,
	POL.OfficeName,Pin.Pincode, CS.ConsignmentStatusName 'ConsignmentStatus', CTD.StatusDate
	From ConsigneeDetails CED
	Inner Join ConsignmentDetails CTD on CED.BookingID = CTD.BookingID
	Inner Join Postal_Pincode_List Pin on Pin.Pincode = CTD.DestinationPincode
	Inner Join Postal_Office_List POL on POL.OfficeID = CTD.DestinationOfficeID
	Inner Join Postal_District_List PDL on POL.DistrictID = PDL.DistrictID
	Inner Join Postal_Division_List PDvL on PDvL.DivisionID = PDL.DivisionID
	Inner Join Postal_Region_List PRL on PRL.RegionID = PDvL.RegionID
	Inner Join Postal_Circle_List PCL on PCL.CircleID = PRL.CircleID
	Inner Join  Postal_State_List PSL on PSL.StateID = PCL.StateID
	Left Join ConsignmentStatus CS on CS.ConsignmentStatusID = CTD.ConsignmentStatusID
	Where 
	CED.BookingID = @BookingID and
	Pin.Active=1 and POL.Active=1 and PDL.Active=1 and PDvL.Active=1 
	and PRL.Active=1 and PCL.Active=1 and PSL.Active=1
END
GO
/****** Object:  StoredProcedure [dbo].[Get_District_Data_by_StateID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 13, 2021
-- Description:	Get District data using State ID
-- ==============================================================
CREATE PROCEDURE [dbo].[Get_District_Data_by_StateID] @DivisionID NVARCHAR(100) 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DistrictID, DistrictName FROM Postal_District_List Where DivisionID=@DivisionID and Active=1
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Division_Data_by_RegionID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 13, 2021
-- Description:	Get Divsion data using Region ID
-- ==============================================================
CREATE PROCEDURE [dbo].[Get_Division_Data_by_RegionID] @RegionID NVARCHAR(100) 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DivisionID, DivisionName FROM Postal_Division_List Where RegionID=@RegionID and Active=1
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Office_Data_by_DistrictID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 13, 2021
-- Description:	Get Office data using District ID
-- ==============================================================
CREATE PROCEDURE [dbo].[Get_Office_Data_by_DistrictID] @DistrictID NVARCHAR(100) 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT OfficeID, OfficeName FROM Postal_Office_List Where DistrictID=@DistrictID and Active=1
END
GO
/****** Object:  StoredProcedure [dbo].[Get_OfficeDetails_By_Pincode]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author: Sai Bhargav Abburu
-- Create date: Mar 29, 2021
-- Description:	Get Office Details by Pincode 

--EXEC [dbo].[Get_OfficeDetails_By_Pincode] 524101
-- =======================================================
CREATE PROCEDURE [dbo].[Get_OfficeDetails_By_Pincode] @pincode int
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT	PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName,
			POL.OfficeName,
			CONCAT(POT.OfficeTypeName,' (',POT.OfficeTypeCode,')') 'OfficeTypeName',
			PDLT.DeliveryType,
			PPL.Pincode

	FROM	Postal_State_List PSL
			INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
			INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
			INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
			INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
			INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
			INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
			INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
			INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID

	WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
	AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1 AND PDLT.DeliveryType='Delivery'
	AND PPL.Pincode = @pincode

	ORDER BY 
			PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName

END
GO
/****** Object:  StoredProcedure [dbo].[Get_Pincode_by_OfficeID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 13, 2021
-- Description:	Get Pincode using Office ID
-- ==============================================================
CREATE PROCEDURE [dbo].[Get_Pincode_by_OfficeID] @OfficeID NVARCHAR(100) 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Pincode FROM Postal_Pincode_List Where OfficeID=@OfficeID and Active=1
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Postal_Circle_Data_by_StateID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 13, 2021
-- Description:	Get Circle List using StateID to bind in drop down
-- =========================================================================
CREATE PROCEDURE [dbo].[Get_Postal_Circle_Data_by_StateID] @StateID NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT CircleID,CircleName FROM Postal_Circle_List WHERE StateID=@StateID and Active=1

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Postal_Region_Data_by_CirleID]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Sai Bhargav Abburu
-- Create date: Mar 13, 2021
-- Description:	Get Region Name using CircleID
-- =============================================
CREATE PROCEDURE [dbo].[Get_Postal_Region_Data_by_CirleID] @CircleID NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT RegionID, RegionName FROM Postal_Region_List WHERE CircleID = @CircleID and Active=1
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Upload_TransactionLog]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--> EXEC [dbo].[Get_Upload_TransactionLog] @userid=N'UR-AVS-M-937216',@from='2021-01-01 00:00:00',@to='2021-05-17 00:00:00',@uploadfiletype=N'txt'

CREATE PROCEDURE [dbo].[Get_Upload_TransactionLog] @userid nvarchar(100), @from datetime, @to datetime, @uploadfiletype nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @dateFrom DATE
	Declare @dateTo DATE

	SET @dateFrom = CONVERT(DATE,@from)
	SET @dateTo = CONVERT(DATE,@to)

	BEGIN
		SELECT 
		  [UploadFileName]
		  ,[UploadFileServerPath]
		  ,[UploadFileDescription]
		  ,[UploadedOn]
		  ,[ServerTransactionID]
		FROM [TestDatabase].[dbo].[UploadTransactionLog]
		Where RIGHT([UploadFileServerPath],5) like '%'+@uploadfiletype+'%'
		AND CAST([UploadedOn] AS DATE) BETWEEN @dateFrom AND @dateTo
	END
	
END
GO
/****** Object:  StoredProcedure [dbo].[Get_User_Details]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 9, 2021
-- Description:	Get User Details

--> EXEC [dbo].[Get_User_Details] 'UR-AVS-M-937216'
-- ==============================================================
CREATE PROCEDURE [dbo].[Get_User_Details] @userid nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT U.UserID
		  ,[first_name] 'First Name'
		  ,[last_name] 'Last Name'
		  ,[gender] 'Gender'
		  ,[email] 'E-Mail'
		  ,U.[Active] 'Active'
		  ,U.[CreatedBy] 'Created By'
		  ,U.[CreatedDate] 'Created On'
		  ,[AuditRefID] 'AuditRefID'
		  ,[Phone] 'Contact#'
		  ,[Username] 'User Name'
		  ,ISNULL(LC.[LoginID],'') 'Login'
		  ,ISNULL(LC.[Password],'') 'Password'
		  ,ISNULL(LC.[Credentials_Ref_ID],'') 'Credentials Ref ID'
	  FROM [dbo].[Users] U
	  LEFT JOIN [dbo].[Login_Credentials] LC on U.Credentails_Ref_Id = LC.Credentials_Ref_ID
	  WHERE U.UserID=@userid
END

GO
/****** Object:  StoredProcedure [dbo].[Get_User_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 09, 2021
-- Description:	Fetch Users List

--> EXEC [dbo].[Get_User_List] 'UR-AVS-M-937216'
-- =============================================
CREATE PROCEDURE [dbo].[Get_User_List] @UserID nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN
		SELECT TOP 10 [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 
		  ORDER BY CreatedDate DESC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[GetAnnouncements]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: Apr 09, 2021
-- Description:	Get Announcements List

--> EXEC GetAnnouncements 'UR-AVS-M-937216','01-Apr-2020', '06-Apr-2021','ALL'
-- =============================================
CREATE PROCEDURE [dbo].[GetAnnouncements] @userid nvarchar(100),@from datetime, @to datetime, @AnnouncementClassification nvarchar(15)
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @datefrom date
	Declare @dateto date

	SET @datefrom = CONVERT(date, @from)
	SET @dateto = CONVERT(date, @to)

	IF(@AnnouncementClassification = 'ALL')
	BEGIN
		Select AnnouncementID, CAST(CreatedDate as Date) CreatedDate,AnnouncementTitle,
		AnnouncementContent, AnnouncementClassification, CASE WHEN Active=1 THEN 'Active' ELSE 'Inactive' END AS 'AnnouncementStatus'
		From Announcements
		Where --Active=1 and --AnnouncementClassification in (@AnnouncementClassification) and
		CAST(CreatedDate as DATE) BETWEEN @datefrom AND @dateto
		Order By 'AnnouncementStatus' 
	END
	ELSE
	BEGIN
		Select AnnouncementID, CAST(CreatedDate as Date) CreatedDate,AnnouncementTitle,
		AnnouncementContent, AnnouncementClassification,  CASE WHEN Active=1 THEN 'Active' ELSE 'Inactive' END AS 'AnnouncementStatus'
		From Announcements
		Where AnnouncementClassification in (@AnnouncementClassification) and
		CAST(CreatedDate as DATE) BETWEEN @datefrom AND @dateto
		Order By 'AnnouncementStatus' 
	END
	

END
GO
/****** Object:  StoredProcedure [dbo].[GetDashBoardData]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: May 15, 2021
-- Description:	Get DashBoard Data
-- =============================================
CREATE PROCEDURE [dbo].[GetDashBoardData] @usertype nvarchar(100), @userid nvarchar(100) 
AS
BEGIN
	SET NOCOUNT ON;

	--EXEC [dbo].[LoadDashboardData] @userid

	IF(@usertype = 'SuperUser')

	SELECT TOP 1 [loginuserrole]
		  ,[TotalConsignmentTillDate]
		  ,[TotalOffices]
		  ,[TotalDeliveryOffices]
		  ,[TotalnonDeliveryOffices]
		  ,[TotalBranchOffices]
		  ,[TotalSubBranchOffices]
		  ,[TotalHeadOffices]
		  ,[AnnualTurnOver]
		  ,[MaintainenceCost]
		  ,[CreatedDate]
	  FROM [dbo].[DashboardData] Where loginuserrole like 'SuperUser%' ORDER BY CreatedDate Desc

END

GO
/****** Object:  StoredProcedure [dbo].[GetHomePageMenu]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Sai Bhargav Abburu
-- Create date: April 3, 2021
-- Description:	Get Menu to Home Page
-- =============================================
CREATE PROCEDURE [dbo].[GetHomePageMenu]
AS
BEGIN
	SET NOCOUNT ON;
	Select MenuID,DisplayName,Controller,ActionMethod,SortOrder from Menu Where Active=1 order by SortOrder ASC
END
GO
/****** Object:  StoredProcedure [dbo].[GetHomePageTime]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Dec 24, 2020
-- Description:	Load Time to home page based on Timezone

--> EXEC [GetHomePageTime] 'UR-AVS-M-937216'
-- =============================================================
CREATE PROCEDURE [dbo].[GetHomePageTime] @userid nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @maxcounter int
	Declare @convertedtime datetime
	Declare @runningcounter int
	Declare @timezone nvarchar(100)
	Declare @usercountry nvarchar(100)

	SELECT @usercountry = Country FROM Users Where UserID = @userid
	SELECT @maxcounter = COUNT(1) FROM TimeZone WHERE Active=1
	SET @runningcounter =1

	IF(ISNULL(@usercountry,'')='')
	BEGIN
		SELECT @usercountry = Country FROM TimeZone Where SortOrder = 1 AND Active=1
	END
	BEGIN
		WHILE (@maxcounter>=@runningcounter)
		BEGIN
			SELECT @timezone = Timezone FROM TimeZone WHERE Sortorder = @runningcounter
			SELECT @convertedtime = [dbo].[ufn_ConvertTimePerTimeZone](@timezone)

			Update TimeZone SET Highlight=NULL,CountryTime = @convertedtime, ModifiedBy=@userid,ModifiedDate=GETDATE() WHERE Sortorder = @runningcounter

			Update TimeZone SET Highlight=1 WHERE Country IN (SELECT Country FROM Users WHERE UserID=@userid)

			SET @runningcounter = @runningcounter+1
		END
	END
	
		SELECT TimezoneID,Country,Timezone,CountryTime,ISNULL(Highlight,0) Highlight, Active FROM TimeZone  ORDER BY Highlight DESC
	
	

END
GO
/****** Object:  StoredProcedure [dbo].[GetMessages]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: Dec 16, 2020
-- Description:	Get Messages using UserID

--> EXEC GetMessages 'UR-AVS-M-937216'
-- =============================================
CREATE PROCEDURE [dbo].[GetMessages] @UserID nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF(ISNULL(@UserID,'') <> '')
	BEGIN
		SELECT M.MessageID, CONCAT(U.first_name,' ',U.last_name) SenderName, CONCAT(US.first_name,' ',US.last_name) ReceiverName,M.MessageSubject,M.[Message],
		ISNULL(M.ReplyRequired,0) ReplyRequired,M.ReplyMessage,ISNULL(M.Acknowledged,0) Acknowledged,M.MessageParentID,M.CreatedDate,M.ReplyDate
		FROM [Messages] M 
		INNER JOIN Users U ON M.SenderID = U.UserID 
		INNER JOIN Users US ON M.ReceiverID = US.UserID
		WHERE M.Active=1 AND U.Active=1 and M.SenderID = @UserID
		ORDER BY M.CreatedDate DESC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_User_Details]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----======================================================================================
-->Execute SP

--EXEC [dbo].[Insert_User_Details]
--		@first_name = N'Rahul',
--		@last_name = N'Kumar',
--		@gender = N'M',
--		@phone = N'91 9656414211',
--		@email = N'ibhargav547@gmail.com',
--		@username = N'rahul_k',
--		@password = N'Rahul@123'
----======================================================================================

CREATE PROCEDURE [dbo].[Insert_User_Details]
@first_name nvarchar(50), 
@last_name nvarchar(50), 
@gender char,
@phone NVARCHAR(50), 
@email nvarchar(50),
@username nvarchar(50),
@password nvarchar(50)

AS

BEGIN --> SP Start

	SET NOCOUNT ON;

	Declare @RegNo NVARCHAR(50)
	Declare @AuditRefID NVARCHAR(50)
	Declare @gendr nvarchar(15)
	Declare @loginID nvarchar(50)
	Declare @cred_id nvarchar(50) = NEWID();
	DECLARE @subject nvarchar(200) = 'Welcome to AVSSB Database..!'
	DECLARE @bodyformat nvarchar(50) = 'HTML'
	DECLARE @emailbody nvarchar(max)

	SET @RegNo = CONCAT('UR-AVS-',LEFT(@gender,1),'-',CONVERT(nvarchar(50),CEILING(RAND()*(1000+5)+5)),CONVERT(nvarchar(50),CEILING(RAND()*(1000+5)+5)))
	SET @AuditRefID = CONCAT('AVSSB-AUDIT-',RIGHT(NEWID(),5))

		IF(@gender='M')
		BEGIN
		SET @gendr='Male'
		END
		IF(@gender='F')
		BEGIN
			SET @gendr='Female'
		END
		IF(@gender='O')
		BEGIN
			SET @gendr='Others'
		END
		IF(@gender='NK')
		BEGIN
			SET @gendr='Not Known'
		END

	EXEC [dbo].[RecordTranSummary] @AuditRefID,'[dbo].[Users]','Create User Details','Started'

	INSERT INTO [dbo].[Users]
			   ([UserID]
			   ,[first_name]
			   ,[last_name]
			   ,[gender]
			   ,[email]
			   ,[Active]
			   ,[CreatedBy]
			   ,[CreatedDate]
			   ,[AuditRefID]
			   ,[Phone]
			   ,[Username]
			   ,[Credentails_Ref_Id])
		 VALUES
			   (@RegNo
			   ,@first_name
			   ,@last_name
			   ,@gendr
			   ,@email
			   ,1
			   ,'SYSTEM'
			   ,GETDATE()
			   ,@AuditRefID
			   ,@phone,
			   @username,@cred_id)

	 EXEC [dbo].[RecordTranSummary] @AuditRefID,'[dbo].[Users]','Create User Details','Completed'

	 EXEC [dbo].[RecordTranSummary] @AuditRefID,'[dbo].[Users]','Create Login Details','Started'

	 SET @loginID = CONCAT(LEFT(@first_name,1),LEFT(@last_name,1),RIGHT(@RegNo,5))

	 INSERT INTO Login_Credentials([Credentials_Ref_ID],[LoginID],[Password],[CreatedBy],[CreatedDate]) VALUES
	 (@cred_id,@loginID,@password,'SYSTEM',GETDATE())

	 EXEC [dbo].[RecordTranSummary] @AuditRefID,'[dbo].[Users]','Create Login Details','Completed'

	 SET @emailbody= 'Dear '+CONCAT(@first_name,' ',@last_name)+',<br/>
	 <br/>
	 Your Login Credentials to Learn MVC application are given below. Please use same to login to application.<br/>
	 <br/>
	 Your Username: '+LTRIM(RTRIM(@RegNo))+'<br/>
	 Your Password: '+LTRIM(RTRIM(@password))+'<br/>
	 <br/>
	 If you face issue while logging in, Please contact Admin. <br/>
	 Please quote Credentials Reference ID- <strong>'+@cred_id+'</strong> for future communications on login issues.<br/>
	 <br/>
	 <strong>
	 Regards,<br/>
	 AVSSB-Autogenerate <br/>
	 </strong>
	 <br/>
	 <p>This is system generated mail. Replies to this mail are not monitored. </p>'


	EXECUTE [dbo].[DB_Mail_Trigger] @email,'ibhargav547@gmail.com',null,@subject,@bodyformat,@emailbody,null,null,null

	select 'User Created'

	 SET NOCOUNT OFF;

END --. SP End


GO
/****** Object:  StoredProcedure [dbo].[InsertAnnouncements]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertAnnouncements] 
@AnnouncementTitle nvarchar(500),
@AnnouncementContent nvarchar(max),
@createdBy nvarchar(100),
@classification nvarchar(10)
AS

Declare @announcementid nvarchar(100) = NEWID()
Declare @createdDate datetime = GETDATE()

BEGIN
	INSERT INTO [dbo].[Announcements]
           ([AnnouncementID]
           ,[AnnouncementTitle]
           ,[AnnouncementContent]
           ,[Active]
           ,[CreatedDate]
           ,[CreatedBy],
		   [AnnouncementClassification])
     VALUES
           (@announcementid,LTRIM(RTRIM(@AnnouncementTitle)),LTRIM(RTRIM(@AnnouncementContent)),1,@createdDate,@createdBy,@classification)

	Select 'Created' Result
END

GO
/****** Object:  StoredProcedure [dbo].[InsertLandingPageImages]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertLandingPageImages]
@landingimagename nvarchar(100),
@LandingImagePath nvarchar(100),
@SortOrder int,
@Createdby nvarchar(100)
AS
BEGIN

Declare @landimageid nvarchar(100) = NEWID();
Declare @createddt datetime = GETDATE();

	INSERT INTO [dbo].[LandingImages]
           ([LandingImageID]
           ,[LandingImageName]
           ,[LandingImagePath]
           ,[SortOrder]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[ModifiedBy]
           ,[ModifiedDate],
		   [Active])
     VALUES
           (@landimageid,@landingimagename,@LandingImagePath,@SortOrder,@Createdby,@createddt,NULL, NULL,1)

	IF @@ERROR = 0
	BEGIN
		Select 'Image Inserted' ImageInserted
	END

END

GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateDeleteTimezone]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: Dec 24, 2020
-- Description:	Insert Update Delete Timezone
-- =============================================
CREATE PROCEDURE [dbo].[InsertUpdateDeleteTimezone]
@userid nvarchar(100),
@action nvarchar(100),
@countryname nvarchar(100),
@timezone nvarchar(100),
@timezoneid nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @adjhrs int
	Declare @adjmins int
	Declare @sortorder int
	Declare @countrytime datetime

	SELECT @adjhrs = LEFT(RIGHT(@timezone,5),2)
	SELECT @adjmins = RIGHT(@timezone,2)
	SELECT @countrytime = [dbo].[ufn_ConvertTimePerTimeZone](@timezone)
	SELECT @sortorder = MAX(SortOrder)+1 FROM TimeZone
	
	IF(LTRIM(RTRIM(@action))='INSERT')
	BEGIN
		INSERT INTO [dbo].[TimeZone]
				([TimezoneID]
				,[Country]
				,[Timezone]
				,[AdjustHours]
				,[AdjustMinutes]
				,[CountryTime]
				,[Sortorder]
				,[Active]
				,[CreatedBy]
				,[CreatedDate])
			VALUES
				(NEWID()
				,@countryname
				,@timezone
				,@adjhrs
				,@adjmins
				,@countrytime
				,@sortorder
				,1
				,@userid
				,GETDATE())

		SELECT 'Inserted' Status
	END

	IF(LTRIM(RTRIM(@action))='UPDATE')
	BEGIN
		Update TimeZone SET
							[Country] = @countryname
							,[Timezone] = @timezone
							,[AdjustHours] = @adjhrs
							,[AdjustMinutes] = @adjmins
							,[CountryTime] = @countrytime
		WHERE TimezoneID = @timezoneid and Active=1

	SELECT 'Updated' Status
	END

	IF(LTRIM(RTRIM(@action))='DELETE')
	BEGIN
		Update TimeZone SET Active=0 WHERE TimezoneID = @timezoneid
		SELECT 'Deleted' Status
	END

	IF(LTRIM(RTRIM(@action))='REACTIVATE')
	BEGIN
		Update TimeZone SET Active=1 WHERE TimezoneID = @timezoneid
		SELECT 'Reactivated' Status
	END

	
END
GO
/****** Object:  StoredProcedure [dbo].[LoadDashboardData]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: MAy 14, 2021
-- Description:	Load Dashboard Data

--> EXEC [dbo].[LoadDashboardData] 'UR-AVS-M-937216'
-- =============================================
CREATE PROCEDURE [dbo].[LoadDashboardData] @userid nvarchar(100)
AS
BEGIN --> SP Begin
	SET NOCOUNT ON;
	
	Declare @loginuserrole nvarchar(100)
	Declare @TotalConsignmentTillDate int
	Declare @TotalOffices int
	Declare @TotalDeliveryOffices int
	Declare @TotalnonDeliveryOffices int
	Declare @TotalBranchOffices int
	Declare @TotalSubBranchOffices int
	Declare @TotalHeadOffices int
	Declare @AnnualTurnOver nvarchar(100)
	Declare @MaintainenceCost nvarchar(100)
	
	IF(ISNULL(@userid, '')='')
	BEGIN
		SET @loginuserrole='StandardUser'
	END

	IF(LTRIM(RTRIM(@userid))='UR-AVS-M-937216')
	BEGIN
		SET @loginuserrole='SuperUser'
	END

	CREATE TABLE #finaldata
	(
		 loginuserrole nvarchar(100),
		 TotalConsignmentTillDate int,
		 TotalOffices int,
		 TotalDeliveryOffices int,
		 TotalnonDeliveryOffices int,
		 TotalBranchOffices int,
		 TotalSubBranchOffices int,
		 TotalHeadOffices int,
		 AnnualTurnOver nvarchar(100),
		 MaintainenceCost nvarchar(100)
	)

		SELECT @TotalConsignmentTillDate = COUNT(1) from ConsignmentDetails
		SELECT @TotalOffices			 = COUNT(1) from [dbo].[Postal_Office_List] Where Active=1
		SELECT @TotalDeliveryOffices	 = COUNT(1) from [dbo].[Postal_Office_List] Where Active=1 AND DeliveryTypeID in (Select DeliveryID FROM [dbo].[Postal_Delivery_Type] Where [DeliveryType] = 'Delivery' and Active=1 ) 
		SELECT @TotalnonDeliveryOffices	 = COUNT(1) from [dbo].[Postal_Office_List] Where Active=1 AND DeliveryTypeID in (Select DeliveryID FROM [dbo].[Postal_Delivery_Type] Where [DeliveryType] = 'Non Delivery' and Active=1 ) 
		SELECT @TotalBranchOffices		 = COUNT(1) from [dbo].[Postal_Office_List] Where Active=1 and OfficeTypeID in (Select OfficeTypeId FROM [dbo].[Postal_Office_Type] Where [OfficeTypeCode] = 'BO' and Active=1)
		SELECT @TotalSubBranchOffices	 = COUNT(1) from [dbo].[Postal_Office_List] Where Active=1 and OfficeTypeID in (Select OfficeTypeId FROM [dbo].[Postal_Office_Type] Where [OfficeTypeCode] = 'SO' and Active=1)
		SELECT @TotalHeadOffices		 = COUNT(1) from [dbo].[Postal_Office_List] Where Active=1 and OfficeTypeID in (Select OfficeTypeId FROM [dbo].[Postal_Office_Type] Where [OfficeTypeCode] = 'HO' and Active=1)


	IF(@loginuserrole = 'SuperUser')
	BEGIN --> SuperUser Start
		
		SELECT @AnnualTurnOver = CONCAT('INR ',CONVERT(NVARCHAR(100),(FLOOR(RAND()*(10000-5+1)+5))*(FLOOR(RAND()*(100-5+1)+5))))
		SELECT @MaintainenceCost = CONCAT('INR ',CONVERT(NVARCHAR(100),(FLOOR(RAND()*(1000-5+1)+5))*(FLOOR(RAND()*(100-5+1)+5))))
		
		INSERT INTO #finaldata(
		loginuserrole,
		TotalConsignmentTillDate,
		TotalOffices,
		TotalDeliveryOffices,
		TotalnonDeliveryOffices,
		TotalBranchOffices,
		TotalSubBranchOffices,
		TotalHeadOffices,
		AnnualTurnOver,
		MaintainenceCost
		)
		SELECT
		CONCAT(@loginuserrole,'[',@userid,']'),
		@TotalConsignmentTillDate,
		@TotalOffices,
		@TotalDeliveryOffices,
		@TotalnonDeliveryOffices,
		@TotalBranchOffices,
		@TotalSubBranchOffices,
		@TotalHeadOffices,
		@AnnualTurnOver,
		@MaintainenceCost
	END --> SuperUser End
	ELSE
	BEGIN --> StandardUser Start

	SET @loginuserrole='StandardUser'
	SET @AnnualTurnOver = ''
	SET @MaintainenceCost = ''

	INSERT INTO #finaldata(
		loginuserrole,
		TotalConsignmentTillDate,
		TotalOffices,
		TotalDeliveryOffices,
		TotalnonDeliveryOffices,
		TotalBranchOffices,
		TotalSubBranchOffices,
		TotalHeadOffices,
		AnnualTurnOver,
		MaintainenceCost
		)
		SELECT 
		CONCAT(@loginuserrole,'[',@userid,']'),
		@TotalConsignmentTillDate,
		@TotalOffices,
		@TotalDeliveryOffices,
		@TotalnonDeliveryOffices,
		@TotalBranchOffices,
		@TotalSubBranchOffices,
		@TotalHeadOffices,
		@AnnualTurnOver,
		@MaintainenceCost
	END --> StandardUser End

	INSERT INTO DashboardData(
		loginuserrole,
		TotalConsignmentTillDate,
		TotalOffices,
		TotalDeliveryOffices,
		TotalnonDeliveryOffices,
		TotalBranchOffices,
		TotalSubBranchOffices,
		TotalHeadOffices,
		AnnualTurnOver,
		MaintainenceCost,
		CreatedDate
		)
	SELECT 
		loginuserrole,
		TotalConsignmentTillDate,
		TotalOffices,
		TotalDeliveryOffices,
		TotalnonDeliveryOffices,
		TotalBranchOffices,
		TotalSubBranchOffices,
		TotalHeadOffices,
		AnnualTurnOver,
		MaintainenceCost,
		GETDATE()
		FROM #finaldata

	DROP TABLE #finaldata
END--> SP End
GO
/****** Object:  StoredProcedure [dbo].[NumbersToWords]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================================================================
-- Author:Sai Bhargav Abburu
-- Create date: Dec 30, 2020
-- Description:Convert Rupees in Numbers to Words upto 99999999999
--

-- EXEC [dbo].[NumbersToWords] 99999999999
/*
RESULT/OUTPUT => Rupees Nine Thousand Nine Hundred and Ninety Nine Crores Ninety Nine Lakh Ninety Nine Thousand Nine Hundred  and Ninety Nine Only
*/
-- ===============================================================================================================================================================
CREATE PROCEDURE [dbo].[NumbersToWords] @value bigint
AS
BEGIN -->SP Start
	SET NOCOUNT ON;
	
	Declare @ones nvarchar(50)
	Declare @tens nvarchar(50)
	Declare @hundreds nvarchar(50) 
	Declare @thousands nvarchar(50)
	Declare @lakhs nvarchar(50)
	Declare @crores nvarchar(50)
	Declare @hundredcrores nvarchar(50)
	Declare @hundred1crores nvarchar(50)
	Declare @hundred2crores nvarchar(50)
	Declare @hundred3crores nvarchar(50)
	Declare @thousandcrores nvarchar(50)
	Declare @valdetect nvarchar(50)
	Declare @result nvarchar(max)
	Declare @tempresult nvarchar(50)
	Declare @templakhresult nvarchar(50)
	Declare @tempcroreresult nvarchar(50)
	Declare @outputvalue nvarchar(max)

	-->Gets the Length of the input value and process it based on length
	 SELECT @valdetect = LEN(@value)

	 IF(@valdetect=1) 
	 BEGIN -->Ones Start
		SELECT @result = WordValue from NumToWords where IntValue=@value
		SELECT @result = CONCAT('Rupees ',@result,' Only')
	 END -->Ones End

	 IF(@valdetect=2)
	 BEGIN --> Tens Start
		 BEGIN
			IF(LEFT(@value,2)%10 = 0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (@value)
				SELECT @result = CONCAT('Rupees ',@tens,' Only')
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue = RIGHT(@value,1) and Placeterm='Ones'
				SELECT @result = CONCAT('Rupees ',IIF((@tens=NULL),'',@tens),' ',IIF((@ones=NULL),'',@ones),' Only')
			END
		 END
		IF(@value between 1 and 9)
		BEGIN
			SELECT @result = Wordvalue from NumToWords where IntValue=@value
			SELECT @result = CONCAT('Rupees ',@result,' Only')
		END
		ELSE IF(@value between 10 and 19)
		BEGIN
			SELECT @result = Wordvalue from NumToWords where IntValue=@value
			SELECT @result = CONCAT('Rupees ',@result,' Only')
		END
	 END --> Tens End

	 IF(@valdetect=3)
	 BEGIN --> Hundreds Start
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		BEGIN
			IF(SUBSTRING(CAST(@value as nvarchar(50)),2,2) between 10 and 11)
			BEGIN
				SELECT @tens = WordValue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,2))
			END
			ELSE
			BEGIN
				IF(RIGHT(@value,2)%10 = 0)
				BEGIN
					SELECT @tens = WordValue from NumToWords where IntValue = RIGHT(@value,2) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				END
				ELSE
				BEGIN
					SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
					SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
				END
			END
		END
		SELECT @result = CONCAT('Rupees ',@hundreds,' Hundred and ',ISNULL(@tens,''),' ',ISNULL(@ones,''),' Only')	
	 END --> Hundreds End
	
	IF(@valdetect=4)
	BEGIN --> Thousands Start
		SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),4,1)
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		SELECT @result = CONCAT('Rupees ',@thousands,' Thousand ',
							IIF((@hundreds=NULL),'',CONCAT(@hundreds,' Hundred and ')),
							IIF(ISNULL(@tens,'NULL')<>'NULL',' and ',''),
							IIF((@tens=NULL),'',@tens),' ',
							IIF((@ones=NULL),'',@ones),' Only')
	END --> Thousands End

	IF(@valdetect=5)
	BEGIN -->Ten Thousands Start
		BEGIN
			IF(LEFT(@value,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = LEFT(@value,2)
				SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(LEFT(@value,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = LEFT(@value,2)
				SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		SELECT @result = CONCAT('Rupees ',
								IIF((ISNULL(@tempresult,'NULL')='NULL'),@thousands,CONCAT(@thousands,' ',@tempresult)),' Thousand ',
								IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),
								IIF(ISNULL(@tens,'NULL')<>'NULL',' and ',''),
								IIF((@tens=NULL),'',@tens),' ',
								IIF((@ones=NULL),'',@ones),' Only')
	END -->Ten Thousands End

	IF(@valdetect=6)
	BEGIN -->Lakh Start
		SELECT @lakhs = WordValue from NumToWords where IntValue = LEFT(@value,1)
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		SELECT @result =REPLACE(
							CONCAT(
									'Rupees ',CONCAT(@lakhs,' Lakh '),
									IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
									IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
									IIF(ISNULL(@tens,'NULL') = 'NULL','  ',' and '),
									IIF((@tens=NULL),'',@tens),' ',
									IIF((@ones=NULL),'',@ones),' Only'
								   ),'  ','')
	END --> Lakh End
	
	IF(@valdetect=7)
	BEGIN --> Ten Lakh Start
		BEGIN
				IF(LEFT(@value,2)%10 = 0)
				BEGIN
					SELECT @lakhs = Wordvalue from NumToWords where IntValue = LEFT(@value,2)
					--SELECT @result = CONCAT('Rupees ',@lakhs,' Only')
				END
				ELSE IF(LEFT(@value,2) between 10 and 19)
				BEGIN
					SELECT @lakhs = Wordvalue  from NumToWords where IntValue = LEFT(@value,2)
					--SELECT @result = CONCAT('Rupees ',@lakhs,' ',' Only')
				END
				ELSE
				BEGIN
					SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
					SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,1))
					--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
				END
		END
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		SELECT @result =REPLACE(
							CONCAT(
									'Rupees ',IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
									IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
									IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
									IIF(ISNULL(@tens,'NULL') = 'NULL','',' and '),
									IIF((@tens=NULL),'',@tens),' ',
									IIF((@ones=NULL),'',@ones),' Only'
								   ),'  ',' ')
	END --> Ten Lakh End

	IF(@valdetect=8)
	BEGIN -->Crores Start
	SELECT @crores = WordValue from NumToWords where IntValue = LEFT(@value,1)
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @lakhs = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		 SELECT @result =REPLACE(
							CONCAT(
									'Rupees ',CONCAT(@crores,' Crore '),
									IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
									IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
									IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
									IIF(ISNULL(@tens,'NULL') <> 'NULL',' and ',''),
									IIF((@tens=NULL),'',@tens),' ',
									IIF((@ones=NULL),'',@ones),' Only'
								   ),'  ',' ')
	END -->Crores End

	IF(@valdetect=9)
	BEGIN -->Ten Crore Start
		BEGIN
				IF(LEFT(@value,2)%10 = 0)
				BEGIN
					SELECT @crores = Wordvalue from NumToWords where IntValue = LEFT(@value,2)
				END
				ELSE IF(LEFT(@value,2) between 10 and 19)
				BEGIN
					SELECT @crores = Wordvalue  from NumToWords where IntValue = LEFT(@value,2)
				END
				ELSE
				BEGIN
					SELECT @crores = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
					SELECT @tempcroreresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,1))
				END
		END
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @lakhs = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
				SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END
		SELECT @result =REPLACE(
							CONCAT(
									'Rupees ',IIF((ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@crores)),'NULL') = 'NULL','',CONCAT(@crores,' Crores ')),CONCAT(@crores,' ',@tempcroreresult,' Crores ')),
									IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
									IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
									IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
									IIF(ISNULL(@tens,'NULL') <> 'NULL',' and ',''),
									IIF((@tens=NULL),'',@tens),' ',
									IIF((@ones=NULL),'',@ones),' Only'
								   ),'  ',' ')
	END --> Ten Crore End

	IF(@valdetect=10)
	BEGIN -->Hundred Crore Start
		SELECT @hundred3crores = WordValue from NumToWords where IntValue = LEFT(@value,1)

		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2)%10 = 0)
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @hundred1crores = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempcroreresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END

		 SELECT @hundredcrores = CONCAT(@hundred3crores,' Hundred ',IIF((ISNULL(@hundred1crores,'NULL')<>'NULL'), CONCAT(' and ',@hundred1crores),''))

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1))
			END
		 END

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2))
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),6,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),7,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		SELECT @result =REPLACE(
							CONCAT(
									'Rupees ',CONCAT(@hundredcrores,' '),
									IIF((ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@crores)),'NULL') = 'NULL','',CONCAT(@crores,' Crores ')),CONCAT(@crores,' ',@tempcroreresult,' Crores ')),
									IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
									IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
									IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
									IIF(ISNULL(@tens,'NULL') <> 'NULL',' and ',''),
									IIF((@tens=NULL),'',@tens),' ',
									IIF((@ones=NULL),'',@ones),' Only'
								   ),'  ',' ')
	END --> Hundred Crore End

	IF(@valdetect=11)
	BEGIN --> Thousand Crore Start
		SELECT @thousandcrores = WordValue from NumToWords where IntValue = LEFT(@value,1)
		SELECT @hundred3crores = WordValue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1))

		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2)%10 = 0)
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2) between 10 and 19)
			BEGIN
				SELECT @hundred1crores = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempcroreresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END

		SELECT @hundredcrores = CONCAT(@hundred3crores,' Hundred ',IIF((ISNULL(@hundred1crores,'NULL')<>'NULL'), CONCAT(' and ',@hundred1crores),''))

				IF(ISNULL(@hundredcrores,'NULL')='NULL')
				BEGIN
					SET @thousandcrores = CONCAT(@thousandcrores,' Thousand Crore ')
				END
				ELSE
				BEGIN
					SET @thousandcrores = CONCAT(@thousandcrores,' Thousand ')
				END
		
				BEGIN
					IF(ISNULL(@crores,'NULL')='NULL' AND ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL')
					BEGIN
						SET @hundredcrores = CONCAT(@hundredcrores,' Crore ')
					END
					ELSE
					BEGIN
						SET @hundredcrores = @hundredcrores
					END
				END
		
		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,1))
			END
		 END

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2))
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),7,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),8,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		SELECT @result =REPLACE(
							CONCAT(
									'Rupees ',
									CONCAT(@thousandcrores, ' '),
									CONCAT(@hundredcrores,' '),
									IIF((ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@crores)),'NULL') = 'NULL','',CONCAT(@crores,' Crores ')),CONCAT(@crores,' ',@tempcroreresult,' Crores ')),
									IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
									IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
									IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
									IIF(ISNULL(@tens,'NULL') <> 'NULL',' and ',''),
									IIF((@tens=NULL),'',@tens),' ',
									IIF((@ones=NULL),'',@ones),' Only'
								   ),'  ',' ')
	END --> Thousand Crore End

	--PRINT REPLACE(@result,'  ',' ') -->Final Output

	IF(@valdetect in (1,2,3)) --> Ones, Tens, Hundreds
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
	END

	IF(@valdetect = 4) --> Thousands
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 5) -->Ten Thousands
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 6) -->Lakhs
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',SUBSTRING(@outputvalue,2,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 7) --> Ten Lakhs
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,2),',',SUBSTRING(@outputvalue,3,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 8) --> Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',SUBSTRING(@outputvalue,2,2),',',SUBSTRING(@outputvalue,4,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 9) --> Ten Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,2),',',SUBSTRING(@outputvalue,3,2),',',SUBSTRING(@outputvalue,5,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 10) --> Hundred Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,3),',',SUBSTRING(@outputvalue,4,2),',',SUBSTRING(@outputvalue,6,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 11) --> Thousand Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',SUBSTRING(@outputvalue,2,3),',',SUBSTRING(@outputvalue,5,2),',',SUBSTRING(@outputvalue,7,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect>11)
	BEGIN
		SET @outputvalue = 'Input value is beyond accepted threshold of stored procedure.Maximum is upto 9,999,99,99,999'
		RAISERROR(@outputvalue,16,2)
		SET @outputvalue = 'ERROR'
	END
	--SELECT @outputvalue 'Entered Value',REPLACE(@result,'  ',' ') 'Words Format'
	IF(@outputvalue <> 'ERROR')
	BEGIN
		PRINT '------Output------'
		PRINT 'The Enter value is INR '
		PRINT '----------------------------'
		PRINT 'INR '+CONVERT(NVARCHAR(100),@outputvalue)
		PRINT ''
		PRINT 'Converted into Words: '
		PRINT '----------------------------'
		PRINT REPLACE(@result,'  ',' ')
	END
	SET NOCOUNT OFF;

END -->SP End
GO
/****** Object:  StoredProcedure [dbo].[NumbersToWords_For_Paise]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author: Sai Bhargav Abburu
-- Create date:Jan 01, 2021
-- Description:	Generate Num to Words for paise
--
-- EXEC [dbo].[NumbersToWords_For_Paise] 11,''
-- ===================================================
CREATE PROCEDURE [dbo].[NumbersToWords_For_Paise]
@value int,
@finalresult nvarchar(max) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @output nvarchar(max)
	Declare @tens nvarchar(50)
	Declare @ones nvarchar(50)

	IF(LEN(@value)=1) --> Prefix Zero Condition
	BEGIN
		select @value
		SELECT @ones = WordValue from NumToWords where IntValue = @value
	END
	ELSE IF((@value%10) = 0) --> Tens condition
	BEGIN
		SELECT @tens = WordValue from NumToWords where IntValue = @value
	END
	ELSE IF(@value between 11 and 19)
	BEGIN
		SELECT @tens = WordValue from NumToWords where IntValue = @value
	END
	ELSE
	BEGIN
		SELECT @tens = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
		SELECT @ones = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,1))
	END
	

	SELECT @finalresult = UPPER(
							REPLACE(
								  CONCAT(
										IIF((ISNULL(@tens,'NULL')='NULL'),'',@tens),' ',
										IIF((ISNULL(@ones,'NULL')='NULL'),'',@ones),' ',
										' paise')
							,'  ',' ')
							)

	--SELECT @finalresult = @output

END
GO
/****** Object:  StoredProcedure [dbo].[NumbersToWords_For_Rupees]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================================================================
-- Author:Sai Bhargav Abburu
-- Create date: Dec 30, 2020
-- Description:Convert Rupees in Numbers to Words upto 99999999999
--

-- EXEC [dbo].[NumbersToWords_For_Rupees] 1000
/*
RESULT/OUTPUT => Rupees Nine Thousand Nine Hundred and Ninety Nine Crores Ninety Nine Lakh Ninety Nine Thousand Nine Hundred  and Ninety Nine Only
*/
-- ===============================================================================================================================================================
CREATE   PROCEDURE [dbo].[NumbersToWords_For_Rupees]
@value bigint,
@currencycountry nvarchar(10) = NULL,
@output nvarchar(max) OUTPUT
AS
BEGIN -->SP Start
	SET NOCOUNT ON;
	
	Declare @ones nvarchar(50)
	Declare @tens nvarchar(50)
	Declare @hundreds nvarchar(50) 
	Declare @thousands nvarchar(50)
	Declare @lakhs nvarchar(50)
	Declare @crores nvarchar(50)
	Declare @hundredcrores nvarchar(50)
	Declare @hundred1crores nvarchar(50)
	Declare @hundred2crores nvarchar(50)
	Declare @hundred3crores nvarchar(50)
	Declare @thousandcrores nvarchar(50)
	Declare @valdetect nvarchar(50)
	Declare @result nvarchar(max)
	Declare @tempresult nvarchar(50)
	Declare @templakhresult nvarchar(50)
	Declare @tempcroreresult nvarchar(50)
	Declare @outputvalue nvarchar(max)
	Declare @currency_result nvarchar(50)

	IF(LEN(@currencycountry)=0)
	BEGIN
		SET @currencycountry = NULL
	END 

	-->Gets the Length of the input value and process it based on length
	 SELECT @valdetect = LEN(@value)

	 IF(@valdetect=1) 
	 BEGIN -->Ones Start
		SELECT @ones = WordValue from NumToWords where IntValue=@value
		--SELECT @result = CONCAT('Rupees ',@result,' Only')
	 END -->Ones End

	 IF(@valdetect=2)
	 BEGIN --> Tens Start
		 BEGIN
			IF(LEFT(@value,2)%10 = 0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (@value)
				--SELECT @result = CONCAT('Rupees ',@tens,' Only')
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue = RIGHT(@value,1) and Placeterm='Ones'
				--SELECT @result = CONCAT('Rupees ',IIF((@tens=NULL),'',@tens),' ',IIF((@ones=NULL),'',@ones),' Only')
			END
		 END
		IF(@value between 1 and 9)
		BEGIN
			SELECT @ones = Wordvalue from NumToWords where IntValue=@value
			--SELECT @result = CONCAT('Rupees ',@result,' Only')
		END
		ELSE IF(@value between 10 and 19)
		BEGIN
			SELECT @tens = Wordvalue from NumToWords where IntValue=@value
			--SELECT @result = CONCAT('Rupees ',@result,' Only')
		END
	 END --> Tens End

	 IF(@valdetect=3)
	 BEGIN --> Hundreds Start
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		BEGIN
			IF(SUBSTRING(CAST(@value as nvarchar(50)),2,2) between 10 and 11)
			BEGIN
				SELECT @tens = WordValue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,2))
			END
			ELSE
			BEGIN
				IF(RIGHT(@value,2)%10 = 0)
				BEGIN
					SELECT @tens = WordValue from NumToWords where IntValue = RIGHT(@value,2) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				END
				ELSE
				BEGIN
					SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
					SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
				END
			END
		END
		--SELECT @result = CONCAT('Rupees ',@hundreds,' Hundred and ',ISNULL(@tens,''),' ',ISNULL(@ones,''),' Only')	
	 END --> Hundreds End
	
	IF(@valdetect=4)
	BEGIN --> Thousands Start
		SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),4,1)
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand ',
		--					IIF((@hundreds=NULL),'',CONCAT(@hundreds,' Hundred and ')),
		--					IIF(ISNULL(@tens,'NULL')<>'NULL',' and ',''),
		--					IIF((@tens=NULL),'',@tens),' ',
		--					IIF((@ones=NULL),'',@ones),' Only')
	END --> Thousands End

	IF(@valdetect=5)
	BEGIN -->Ten Thousands Start
		BEGIN
			IF(LEFT(@value,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = LEFT(@value,2)
				--SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(LEFT(@value,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = LEFT(@value,2)
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		--SELECT @result = CONCAT('Rupees ',
		--						IIF((ISNULL(@tempresult,'NULL')='NULL'),@thousands,CONCAT(@thousands,' ',@tempresult)),' Thousand ',
		--						IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),
		--						IIF(ISNULL(@tens,'NULL')<>'NULL',' and ',''),
		--						IIF((@tens=NULL),'',@tens),' ',
		--						IIF((@ones=NULL),'',@ones),' Only')
	END -->Ten Thousands End

	IF(@valdetect=6)
	BEGIN -->Lakh Start
		SELECT @lakhs = WordValue from NumToWords where IntValue = LEFT(@value,1)
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		--SELECT @result =REPLACE(
		--					CONCAT(
		--							'Rupees ',CONCAT(@lakhs,' Lakh '),
		--							IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
		--							IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
		--							IIF(ISNULL(@tens,'NULL') = 'NULL','  ',' and '),
		--							IIF((@tens=NULL),'',@tens),' ',
		--							IIF((@ones=NULL),'',@ones),' Only'
		--						   ),'  ','')
	END --> Lakh End
	
	IF(@valdetect=7)
	BEGIN --> Ten Lakh Start
		BEGIN
				IF(LEFT(@value,2)%10 = 0)
				BEGIN
					SELECT @lakhs = Wordvalue from NumToWords where IntValue = LEFT(@value,2)
					--SELECT @result = CONCAT('Rupees ',@lakhs,' Only')
				END
				ELSE IF(LEFT(@value,2) between 10 and 19)
				BEGIN
					SELECT @lakhs = Wordvalue  from NumToWords where IntValue = LEFT(@value,2)
					--SELECT @result = CONCAT('Rupees ',@lakhs,' ',' Only')
				END
				ELSE
				BEGIN
					SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
					SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,1))
					--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
				END
		END
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		--SELECT @result =REPLACE(
		--					CONCAT(
		--							'Rupees ',IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
		--							IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
		--							IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
		--							IIF(ISNULL(@tens,'NULL') = 'NULL','',' and '),
		--							IIF((@tens=NULL),'',@tens),' ',
		--							IIF((@ones=NULL),'',@ones),' Only'
		--						   ),'  ',' ')
	END --> Ten Lakh End

	IF(@valdetect=8)
	BEGIN -->Crores Start
	SELECT @crores = WordValue from NumToWords where IntValue = LEFT(@value,1)
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @lakhs = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		 --SELECT @result =REPLACE(
			--				CONCAT(
			--						'Rupees ',CONCAT(@crores,' Crore '),
			--						IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
			--						IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
			--						IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
			--						IIF(ISNULL(@tens,'NULL') <> 'NULL',' and ',''),
			--						IIF((@tens=NULL),'',@tens),' ',
			--						IIF((@ones=NULL),'',@ones),' Only'
			--					   ),'  ',' ')
	END -->Crores End

	IF(@valdetect=9)
	BEGIN -->Ten Crore Start
		BEGIN
				IF(LEFT(@value,2)%10 = 0)
				BEGIN
					SELECT @crores = Wordvalue from NumToWords where IntValue = LEFT(@value,2)
				END
				ELSE IF(LEFT(@value,2) between 10 and 19)
				BEGIN
					SELECT @crores = Wordvalue  from NumToWords where IntValue = LEFT(@value,2)
				END
				ELSE
				BEGIN
					SELECT @crores = Wordvalue from NumToWords where IntValue like (CONCAT(LEFT(@value,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
					SELECT @tempcroreresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CAST(@value as nvarchar(50)),2,1))
				END
		END
		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @lakhs = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Only')
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END
		--SELECT @result =REPLACE(
		--					CONCAT(
		--							'Rupees ',IIF((ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@crores)),'NULL') = 'NULL','',CONCAT(@crores,' Crores ')),CONCAT(@crores,' ',@tempcroreresult,' Crores ')),
		--							IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
		--							IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
		--							IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
		--							IIF(ISNULL(@tens,'NULL') <> 'NULL',' and ',''),
		--							IIF((@tens=NULL),'',@tens),' ',
		--							IIF((@ones=NULL),'',@ones),' Only'
		--						   ),'  ',' ')
	END --> Ten Crore End

	IF(@valdetect=10)
	BEGIN -->Hundred Crore Start
		SELECT @hundred3crores = WordValue from NumToWords where IntValue = LEFT(@value,1)

		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2)%10 = 0)
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2) between 10 and 19)
			BEGIN
				SELECT @hundred1crores = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempcroreresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END

		 SELECT @hundredcrores = CONCAT(@hundred3crores,' Hundred ',IIF((ISNULL(@hundred1crores,'NULL')<>'NULL'), CONCAT(' and ',@hundred1crores),''))

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,2))
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1))
			END
		 END

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,2))
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),6,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),7,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END

		--SELECT @result =REPLACE(
		--					CONCAT(
		--							'Rupees ',CONCAT(@hundredcrores,' '),
		--							IIF((ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@crores)),'NULL') = 'NULL','',CONCAT(@crores,' Crores ')),CONCAT(@crores,' ',@tempcroreresult,' Crores ')),
		--							IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
		--							IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
		--							IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
		--							IIF(ISNULL(@tens,'NULL') <> 'NULL',' and ',''),
		--							IIF((@tens=NULL),'',@tens),' ',
		--							IIF((@ones=NULL),'',@ones),' Only'
		--						   ),'  ',' ')
	END --> Hundred Crore End

	IF(@valdetect=11)
	BEGIN --> Thousand Crore Start
		SELECT @thousandcrores = WordValue from NumToWords where IntValue = LEFT(@value,1)
		SELECT @hundred3crores = WordValue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),2,1))

		BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2)%10 = 0)
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2) between 10 and 19)
			BEGIN
				SELECT @hundred1crores = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),3,2))
				--SELECT @result = CONCAT('Rupees ',@thousands,' Thousand',' Only')
			END
			ELSE
			BEGIN
				SELECT @hundred1crores = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),3,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempcroreresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),4,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END

		SELECT @hundredcrores = CONCAT(@hundred3crores,' Hundred ',IIF((ISNULL(@hundred1crores,'NULL')<>'NULL'), CONCAT(' and ',@hundred1crores),''))

				IF(ISNULL(@hundredcrores,'NULL')='NULL')
				BEGIN
					SET @thousandcrores = CONCAT(@thousandcrores,' Thousand Crore ')
				END
				ELSE
				BEGIN
					SET @thousandcrores = CONCAT(@thousandcrores,' Thousand ')
				END
		
				BEGIN
					IF(ISNULL(@crores,'NULL')='NULL' AND ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL')
					BEGIN
						SET @hundredcrores = CONCAT(@hundredcrores,' Crore ')
					END
					ELSE
					BEGIN
						SET @hundredcrores = @hundredcrores
					END
				END
		
		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2)%10 = 0)
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2) between 10 and 19)
			BEGIN
				SELECT @lakhs = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),5,2))
			END
			ELSE
			BEGIN
				SELECT @lakhs = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),5,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @templakhresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),6,1))
			END
		 END

		 BEGIN
			IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2)%10 = 0)
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2))
			END
			ELSE IF(SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2) between 10 and 19)
			BEGIN
				SELECT @thousands = Wordvalue  from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),7,2))
			END
			ELSE
			BEGIN
				SELECT @thousands = Wordvalue from NumToWords where IntValue like (CONCAT(SUBSTRING(CONVERT(NVARCHAR(50),@value),7,1),'%')) and RIGHT(WordValue,3) like ('%ty') and Placeterm='Tens'
				SELECT @tempresult = Wordvalue from NumToWords where IntValue = CONVERT(INT,SUBSTRING(CONVERT(NVARCHAR(50),@value),8,1))
				--SELECT @result = CONCAT('Rupees ',@thousands,' ',@tempresult,' Thousand',' Only')
			END
		 END
		--SELECT @thousands = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),5,1) 
		SELECT @hundreds = Wordvalue from NumToWords where IntValue =SUBSTRING(REVERSE(@value),3,1)
		--select @hundreds as '@hundreds'

		BEGIN
			IF(SUBSTRING(REVERSE(@value),1,1)=0)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where LEFT(IntValue,1) like (SUBSTRING(REVERSE(@value),2,1)) and RIGHT(IntValue,1)=0 
			END
			ELSE IF(RIGHT(@value,2) between 10 and 19)
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue=RIGHT(@value,2)
			END
			ELSE
			BEGIN
				SELECT @tens = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),2,1)+'%') and Placeterm='Tens'
				SELECT @ones = Wordvalue from NumToWords where IntValue like (SUBSTRING(REVERSE(@value),1,1)+'%') and Placeterm='Ones'
			END
		END
	END --> Thousand Crore End

	--RESULT-->
	SELECT @result =REPLACE(
							CONCAT(
									CASE	
										WHEN (@currencycountry = 'USA')		THEN 'USD'
										WHEN (@currencycountry = 'UK')		THEN 'GBP'
										WHEN (@currencycountry = 'Europe')	THEN 'EUR'
										ELSE 'Rupees '
									END,
									CONCAT(@thousandcrores, ' '),
									CONCAT(@hundredcrores,' '),
									IIF((ISNULL(LTRIM(RTRIM(@tempcroreresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@crores)),'NULL') = 'NULL','',CONCAT(@crores,' Crores ')),CONCAT(@crores,' ',@tempcroreresult,' Crores ')),
									IIF((ISNULL(LTRIM(RTRIM(@templakhresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@lakhs)),'NULL') = 'NULL','',CONCAT(@lakhs,' Lakh ')),CONCAT(@lakhs,' ',@templakhresult,' Lakh ')),
									IIF((ISNULL(LTRIM(RTRIM(@tempresult)),'NULL') = 'NULL'),IIF(ISNULL(LTRIM(RTRIM(@thousands)),'NULL') = 'NULL','',CONCAT(@thousands,' Thousand ')),CONCAT(@thousands,' ',@tempresult,' Thousand ')),
									IIF((ISNULL(@hundreds,'NULL')='NULL'),'',CONCAT(@hundreds,' Hundred ')),' ',
									IIF((ISNULL(@tens,'NULL') <> 'NULL' and @valdetect not in (1,2)),' and ',''),
									IIF((@tens=NULL),'',@tens),' ',
									IIF((@ones=NULL),'',@ones)--,' Only'
								   ),'  ',' ')

	--PRINT REPLACE(@result,'  ',' ') -->Final Output

	IF(@valdetect in (1,2,3)) --> Ones, Tens, Hundreds
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
	END

	IF(@valdetect = 4) --> Thousands
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 5) -->Ten Thousands
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 6) -->Lakhs
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',SUBSTRING(@outputvalue,2,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 7) --> Ten Lakhs
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,2),',',SUBSTRING(@outputvalue,3,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 8) --> Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',SUBSTRING(@outputvalue,2,2),',',SUBSTRING(@outputvalue,4,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 9) --> Ten Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,2),',',SUBSTRING(@outputvalue,3,2),',',SUBSTRING(@outputvalue,5,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 10) --> Hundred Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,3),',',SUBSTRING(@outputvalue,4,2),',',SUBSTRING(@outputvalue,6,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect = 11) --> Thousand Crores
	BEGIN
		SET @outputvalue = CONVERT(NVARCHAR(50),@value)
		SET @outputvalue = CONCAT(LEFT(@outputvalue,1),',',SUBSTRING(@outputvalue,2,3),',',SUBSTRING(@outputvalue,5,2),',',SUBSTRING(@outputvalue,7,2),',',RIGHT(@outputvalue,3))
	END

	IF(@valdetect>11)
	BEGIN
		SET @outputvalue = 'Input value is beyond accepted threshold of stored procedure.Maximum is upto 9,999,99,99,999'
		RAISERROR(@outputvalue,16,2)
		SET @outputvalue = 'ERROR'
	END

	--SET @outputvalue = CONCAT(@outputvalue,'.00')

	--SELECT @outputvalue 'Entered Value',REPLACE(@result,'  ',' ') 'Words Format'
	IF(@outputvalue <> 'ERROR')
	BEGIN
		PRINT '------Output------'
		PRINT 'The Enter value is '+' '+CASE	
											WHEN (@currencycountry = 'USA')		THEN 'USD'
											WHEN (@currencycountry = 'UK')		THEN 'GBP'
											WHEN (@currencycountry = 'Europe')	THEN 'EUR'
											ELSE 'INR '
										END
		PRINT '----------------------------'
		PRINT CASE	
				WHEN (@currencycountry = 'USA')		THEN 'USD'
				WHEN (@currencycountry = 'UK')		THEN 'GBP'
				WHEN (@currencycountry = 'Europe')	THEN 'EUR'
				ELSE 'INR '
			END +' '+ CONVERT(NVARCHAR(100),@outputvalue)
		PRINT ''
		PRINT 'Converted into Words: '
		PRINT '----------------------------'
		PRINT UPPER(REPLACE(@result,'  ',' '))
	END

	SELECT UPPER(REPLACE(@result,'  ',' '))

	SELECT @output = UPPER(@result)

	SET NOCOUNT OFF;

END -->SP End
GO
/****** Object:  StoredProcedure [dbo].[Process_OfficeDetails_Uploaded_Data]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================
-- Author: Sai Bhargav Abburu
-- Create date: Mar 16, 2021
-- Description:	Process data in data staging table and map it to orignal data tables
--> Parameter -> StageTransactionID

--> EXEC [dbo].[Process_OfficeDetails_Uploaded_Data] '28c376d8-c5c8-4595-863c-9fea8fb7ba72'
-- ===========================================================================================
CREATE PROCEDURE [dbo].[Process_OfficeDetails_Uploaded_Data] @StageTransactionID NVARCHAR(100)
AS
BEGIN --> SP Start

	SET NOCOUNT ON;

	Declare @DataProcessID NVARCHAR(100)
	Declare @uploadTranID NVARCHAR(100)
	Declare @processtart datetime
	Declare @processend datetime
	Declare @processStatus NVARCHAR(20)
	Declare @uploadFilename NVARCHAR(100)
	Declare @createdby NVARCHAR(50)
	Declare @statecounter int
	Declare @Circlecounter int
	Declare @Regioncounter int
	Declare @Divisioncounter int
	Declare @Districtcounter int
	Declare @Officecounter int
	Declare @Officetypecounter int
	Declare @deliverycounter int
	Declare @pincodecounter int
	Declare @runningcounter int

	SET @DataProcessID = NEWID()
	SET @processtart = GETDATE()
	SET @processStatus = 'Started'
	SET @runningcounter = 1

	SELECT @uploadTranID = UploadTransactionID FROM UploadTransactionLog Where ServerTransactionID = @StageTransactionID
	SELECT @uploadFilename = UploadFileName FROM UploadTransactionLog Where UploadTransactionID = @uploadTranID
	SELECT @createdby = UploadedBy FROM UploadTransactionLog Where UploadTransactionID = @uploadTranID


	INSERT INTO [dbo].[Data_Process_Log]
           ([DataProcessTranID]
           ,[ServerTransactionID]
           ,[UploadTransactionID]
           ,[UploadFileName]
           ,[ProcessStart]
           ,[ProcessStatus]
           ,[CreatedBy]
           ,[CreatedDate])
     VALUES
	 (@DataProcessID,@StageTransactionID,@uploadTranID,@uploadFilename,@processtart,@processStatus,@createdby,GETDATE())
	--INSERT INTO DataProcessLog(DataProcessTranID,ServerTransactionID,UploadTransactionID,UploadFileName,ProcessStart,ProcessStatus,
	--CreatedBy,CreatedDate) VALUES
	--(@DataProcessID,@StageTransactionID,@uploadTranID,@uploadFilename,@processtart,@processStatus,@createdby,GETDATE())

	SELECT @statecounter		= COUNT(DISTINCT([State])) FROM Postal_Data_Staging WHERE LTRIM(RTRIM([State])) NOT IN (SELECT StateName FROM Postal_State_List WHERE Active=1)
	SELECT @Circlecounter		= COUNT(DISTINCT(CircleName)) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(CircleName)) NOT IN (SELECT CircleName FROM Postal_Circle_List WHERE Active=1)
	SELECT @Regioncounter		= COUNT(DISTINCT(RegionName)) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(RegionName)) NOT IN (SELECT RegionName FROM Postal_Region_List WHERE Active=1)
	SELECT @Divisioncounter		= COUNT(DISTINCT(DivisionName)) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(DivisionName)) NOT IN (SELECT DivisionName FROM Postal_Division_List WHERE Active=1)
	SELECT @Districtcounter		= COUNT(DISTINCT(District)) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(District)) NOT IN (SELECT District FROM Postal_District_List WHERE Active=1)
	SELECT @Officecounter		= COUNT(DISTINCT(OfficeName)) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(OfficeName)) NOT IN (SELECT OfficeName FROM Postal_Office_List WHERE Active=1)
	SELECT @Officetypecounter	= COUNT(DISTINCT(OfficeType)) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(OfficeType)) NOT IN (SELECT OfficeType FROM Postal_Office_Type WHERE Active=1)
	SELECT @deliverycounter		= COUNT(DISTINCT(Delivery)) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(Delivery)) NOT IN (SELECT Delivery FROM Postal_Delivery_Type WHERE Active=1)
	SELECT @pincodecounter		= COUNT(Pincode) FROM Postal_Data_Staging WHERE LTRIM(RTRIM(Pincode)) NOT IN (SELECT Pincode FROM Postal_Pincode_List WHERE Active=1)

	BEGIN-->State Insert Start
		Declare @statename nvarchar(100)

		SELECT DISTINCT [State], ROW_NUMBER() OVER(order by [State]) as rows INTO #STATETEMPTABLE FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM([State])) NOT IN (SELECT StateName FROM Postal_State_List WHERE Active=1)
				GROUP BY [State]

		--SELECT * FROM #STATETEMPTABLE
		
		WHILE(@statecounter >= @runningcounter)
		BEGIN -->State Insert While Start
	
			SELECT @statename = [State] FROM #STATETEMPTABLE WHERE rows=@runningcounter

			INSERT INTO Postal_State_List([StateID],[StateName],[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@statename,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->State Insert While End

	SET @runningcounter = 1
	END -->State Insert End

	BEGIN-->Circle Insert Start
		Declare @Circlename nvarchar(100)
		Declare @StateID NVARCHAR(100)

		SELECT DISTINCT CircleName, ROW_NUMBER() OVER(order by CircleName) as rows INTO #CircleTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(CircleName)) NOT IN (SELECT CircleName FROM Postal_Circle_List WHERE Active=1)
				GROUP BY CircleName

		--SELECT * FROM #CircleTempTable
		
		WHILE(@Circlecounter >= @runningcounter)
		BEGIN -->Circle Insert While Start
	
			SELECT @Circlename = CircleName FROM #CircleTempTable WHERE rows = @runningcounter
			SELECT @StateID = StateID FROM Postal_State_List Where StateName in (Select [State] from Postal_Data_Staging 
																							Where CircleName=@Circlename)

			INSERT INTO Postal_Circle_List(CircleID,[StateID],CircleName,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@StateID,@Circlename,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->Circle Insert While End
	SET @runningcounter=1
	END -->Circle Insert End
	
	BEGIN-->Region Insert Start
		Declare @Regionname nvarchar(100)
		Declare @CircleID NVARCHAR(100)

		SELECT DISTINCT RegionName, ROW_NUMBER() OVER(order by RegionName) as rows INTO #RegionTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(RegionName)) NOT IN (SELECT RegionName FROM Postal_Region_List WHERE Active=1)
				GROUP BY RegionName

		--SELECT * FROM #RegionTempTable
		
		WHILE(@Regioncounter >= @runningcounter)
		BEGIN -->Region Insert While Start
	
			SELECT @Regionname = RegionName FROM #RegionTempTable WHERE rows = @runningcounter
			SELECT @CircleID = CircleID FROM Postal_Circle_List Where CircleName in (Select CircleName from Postal_Data_Staging 
																							Where RegionName=@Regionname)

			INSERT INTO Postal_Region_List(RegionID,[CircleID],RegionName,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@CircleID,@Regionname,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->Region Insert While End
	SET @runningcounter=1
	END -->Region Insert End

	BEGIN-->Division Insert Start
		Declare @Divisionname nvarchar(100)
		Declare @RegionID NVARCHAR(100)

		SELECT DISTINCT DivisionName, ROW_NUMBER() OVER(order by DivisionName) as rows INTO #DivisionTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(DivisionName)) NOT IN (SELECT DivisionName FROM Postal_Division_List WHERE Active=1)
				GROUP BY DivisionName

		--SELECT * FROM #DivisionTempTable
		
		WHILE(@Divisioncounter >= @runningcounter)
		BEGIN -->Division Insert While Start
	
			SELECT @Divisionname = DivisionName FROM #DivisionTempTable WHERE rows = @runningcounter
			SELECT @RegionID = RegionID FROM Postal_Region_List Where RegionName in (Select RegionName from Postal_Data_Staging 
																							Where DivisionName=@Divisionname)

			INSERT INTO Postal_Division_List(DivisionID,[RegionID],DivisionName,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@RegionID,@Divisionname,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->Division Insert While End
	SET @runningcounter=1
	END -->Division Insert End

	BEGIN-->District Insert Start
		Declare @Districtname nvarchar(100)
		Declare @DivisionID NVARCHAR(100)

		SELECT DISTINCT District, ROW_NUMBER() OVER(order by District) as rows INTO #DistrictTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(District)) NOT IN (SELECT DistrictName FROM Postal_District_List WHERE Active=1)
				GROUP BY District

		--SELECT * FROM #DistrictTempTable
		
		WHILE(@Districtcounter >= @runningcounter)
		BEGIN -->District Insert While Start
	
			SELECT @Districtname = District FROM #DistrictTempTable WHERE rows = @runningcounter
			SELECT @DivisionID = DivisionId FROM Postal_Division_List Where DivisionName in (Select DivisionName from Postal_Data_Staging 
																							Where District=@Districtname)

			INSERT INTO Postal_District_List(DistrictID,DivisionID,DistrictName,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@DivisionID,@Districtname,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->District Insert While End
	SET @runningcounter=1
	END -->District Insert End

	BEGIN-->Office Insert Start
		Declare @Officename nvarchar(100)
		Declare @DistrictID nvarchar(100)

		SELECT DISTINCT OfficeName, ROW_NUMBER() OVER(order by OfficeName) as rows INTO #OfficeTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(District)) NOT IN (SELECT OfficeName FROM Postal_Office_List WHERE Active=1)
				GROUP BY OfficeName

		--SELECT * FROM #OfficeTempTable
		
		WHILE(@Officecounter >= @runningcounter)
		BEGIN -->Office Insert While Start
	
			SELECT @Officename = OfficeName FROM #OfficeTempTable WHERE rows = @runningcounter
			SELECT @DistrictID = DistrictID FROM Postal_District_List Where DistrictName in (Select District from Postal_Data_Staging 
																							Where OfficeName=@Officename)


			INSERT INTO Postal_Office_List(OfficeID,[DistrictID],OfficeName,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@DistrictID,@Officename,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->Office Insert While End
	SET @runningcounter=1
	END -->Office Insert End

	BEGIN-->Office Type Insert Start
		Declare @OfficeTypename nvarchar(100)
		Declare @OfficeTypeID NVARCHAR(5)

		SELECT DISTINCT OfficeType, ROW_NUMBER() OVER(order by OfficeType) as rows INTO #OfficeTypeTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(OfficeType)) NOT IN (SELECT OfficeTypeCode FROM Postal_Office_Type WHERE Active=1)
				GROUP BY OfficeType

		--SELECT * FROM #OfficeTypeTempTable
		
		WHILE(@Officetypecounter >= @runningcounter)
		BEGIN -->Office Type Insert While Start
	
			SELECT @OfficeTypeID = OfficeType FROM #OfficeTypeTempTable WHERE rows = @runningcounter

			INSERT INTO Postal_Office_Type(OfficeTypeID,OfficeTypeName,OfficeTypeCode,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),'',@OfficeTypeID,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->Office Type Insert While End

		Update Postal_Office_Type SET OfficeTypeName='Branch Post Office' WHERE OfficeTypeCode='BO'
		Update Postal_Office_Type SET OfficeTypeName='Sub Post Office' WHERE OfficeTypeCode='SO'
		Update Postal_Office_Type SET OfficeTypeName='Head Post Office' WHERE OfficeTypeCode='HO'

		Update Postal_Office_List SET OfficeTypeID = (SELECT OfficeTypeID FROM Postal_Office_Type WHERE OfficeTypeCode='BO')
		WHERE OfficeName in (SELECT OfficeName FROM Postal_Data_Staging WHERE OfficeType='BO')

		Update Postal_Office_List SET OfficeTypeID = (SELECT OfficeTypeID FROM Postal_Office_Type WHERE OfficeTypeCode='SO')
		WHERE OfficeName in (SELECT OfficeName FROM Postal_Data_Staging WHERE OfficeType='SO')

		Update Postal_Office_List SET OfficeTypeID = (SELECT OfficeTypeID FROM Postal_Office_Type WHERE OfficeTypeCode='HO')
		WHERE OfficeName in (SELECT OfficeName FROM Postal_Data_Staging WHERE OfficeType='HO')

	SET @runningcounter=1
	END -->Office Type Insert End
	
	BEGIN-->Delivery Insert Start
		Declare @DeliveryName nvarchar(100)

		SELECT DISTINCT Delivery, ROW_NUMBER() OVER(order by Delivery) as rows INTO #DeliveryTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(Delivery)) NOT IN (SELECT Delivery FROM Postal_Delivery_Type WHERE Active=1)
				GROUP BY Delivery

		--SELECT * FROM #DeliveryTempTable
		
		WHILE(@deliverycounter >= @runningcounter)
		BEGIN -->Delivery Insert While Start
	
			SELECT @DeliveryName = Delivery FROM #DeliveryTempTable WHERE rows = @runningcounter

			INSERT INTO Postal_Delivery_Type(DeliveryID,DeliveryType,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@DeliveryName,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->Delivery Insert While End

		Update Postal_Office_List SET DeliveryTypeID = (SELECT DeliveryID FROM Postal_Delivery_Type WHERE LTRIM(RTRIM(DeliveryType))='Delivery')
		WHERE OfficeName in (SELECT OfficeName FROM Postal_Data_Staging WHERE Delivery='Delivery')

		Update Postal_Office_List SET DeliveryTypeID = (SELECT DeliveryID FROM Postal_Delivery_Type WHERE LTRIM(RTRIM(DeliveryType))='Non Delivery')
		WHERE OfficeName in (SELECT OfficeName FROM Postal_Data_Staging WHERE Delivery='Non Delivery')

	SET @runningcounter=1
	END -->Delivery Insert End

	BEGIN-->Pincode Insert Start
		Declare @pincode INT
		Declare @officeid NVARCHAR(100)

		SELECT OfficeName, Pincode, ROW_NUMBER() OVER(order by Pincode) as rows INTO #PincodeTempTable FROM Postal_Data_Staging
				WHERE LTRIM(RTRIM(Pincode)) NOT IN (SELECT Pincode FROM Postal_Pincode_List WHERE Active=1)
				GROUP BY OfficeName,Pincode
				

		--SELECT * FROM #PincodeTempTable
		
		WHILE(@pincodecounter >= @runningcounter)
		BEGIN -->Pincode Insert While Start
	
			SELECT @pincode = Pincode FROM #PincodeTempTable WHERE rows = @runningcounter
			SELECT @officeid = OfficeID From Postal_Office_List WHERE OfficeName in (SELECT OfficeName FROM #PincodeTempTable WHERE Pincode=@pincode and rows=@runningcounter)

			INSERT INTO Postal_Pincode_List(PincodeID,[OfficeID],Pincode,[Active],[CreatedBy],[CreatedDate])
			VALUES (NEWID(),@officeid,@pincode,1,@createdby,GETDATE())

		SET @runningcounter = @runningcounter+1
		END -->Pincode Insert While End
	SET @runningcounter=1
	END -->Pincode Insert End


	SET @processStatus = 'Completed'
	SET @processend = GETDATE()

	UPDATE [Data_Process_Log] SET ProcessStart = @processtart, ProcessStatus = @processStatus, ProcessEnd = @processend
	WHERE DataProcessTranID = @DataProcessID

	DROP TABLE #STATETEMPTABLE
	DROP TABLE #CircleTempTable
	DROP TABLE #RegionTempTable
	DROP TABLE #DivisionTempTable
	DROP TABLE #DistrictTempTable
	DROP TABLE #OfficeTempTable
	DROP TABLE #OfficeTypeTempTable
	DROP TABLE #DeliveryTempTable
	DROP TABLE #PincodeTempTable
END --> SP End
GO
/****** Object:  StoredProcedure [dbo].[Record_Upload_Transaction_Log]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:	SAI BHARGAV ABBURU
-- Create date: MAR 13, 2021
-- Description:	RECORD UPLOAD FILE TRANSACTION LOG
-- =======================================================
CREATE PROCEDURE [dbo].[Record_Upload_Transaction_Log] 
@UploadServerTranID nvarchar(50),
@uploadfilename nvarchar(50),
@filepath nvarchar(max),
@descr nvarchar(100),
@createdby nvarchar(20),
@createddate datetime
AS
BEGIN
	SET NOCOUNT ON;

	Declare @tranid nvarchar(100);

	SET @createddate = GETDATE();
	SET @tranid = NEWID();

	INSERT INTO [dbo].[UploadTransactionLog]
           ([UploadTransactionID]
           ,[UploadFileName]
           ,[UploadFileServerPath]
           ,[UploadFileDescription]
           ,[UploadedBy]
           ,[UploadedOn],
		    [ServerTransactionID])
     VALUES
           (@tranid,@uploadfilename,@filepath,@descr,@createdby,@createddate,@UploadServerTranID)

END

GO
/****** Object:  StoredProcedure [dbo].[RecordTranSummary]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		Sai Bhargav Abburu
-- Create date: Nov 28, 2020
-- Description:	Records Transaction Summary
-- EXEC [dbo].[RecordTranSummary] 'AVSSB-LOAN-20201129-FF035','[dbo].[LoanDetails]','Loan Generated','Pending for Approval'
-- ==========================================================================================
CREATE PROCEDURE [dbo].[RecordTranSummary]
@AuditRefId nvarchar(50),
@ActionOn nvarchar(200),
@Action nvarchar(200),
@ActionStatus nvarchar(200)
AS
BEGIN
	SET NOCOUNT ON;

	declare @TranId nvarchar(50)=NEWID()

	Insert into [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
	Values (@TranId,@AuditRefId,@ActionOn,@Action,@ActionStatus,'SYSTEM',GETDATE())

END
GO
/****** Object:  StoredProcedure [dbo].[Report_Get_AutoGeneratedData]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --=================================================================================
 --Author:	Sai Bhargav Abburu
 --Create date: Mar 06, 2021
 --Description:	Get the Auto-generated data on to screen and bind to table
 --Parameters:-
	--1. @type = 1 -> Auto-Generated Dates OR @type=2 -> Auto-Generated Names

-- EXEC [Get_AutoGeneratedData] 1 -->Auto Generated Dates
-- EXEC [Get_AutoGeneratedData] 2 -->Auto Generated Names
 --=================================================================================
CREATE PROCEDURE [dbo].[Report_Get_AutoGeneratedData] @type int, @AuditRefID NVARCHAR(50)
AS
BEGIN --> SP Start
	SET NOCOUNT ON;

Declare @TranID NVARCHAR(50) = NEWID()
Declare @AuditID NVARCHAR(50) 

IF(@AuditRefID IS NULL)
	BEGIN
		SET @AuditRefID =''
	END
SET @AuditID = CONCAT('AVSSB-GENDT-',REPLACE(CAST(GETDATE() as DATE),'-',''),'-',RIGHT(NEWID(),5))

	IF(@type = 101)
	BEGIN --> Auto-Generated Dates - START

		BEGIN TRY
			EXEC [dbo].[RecordTranSummary] @AuditID,'[dbo].[AutoGeneratedDates]','Generate Data','Started'

			SELECT [Date] 'Date'
					,[Month] 'Month'
					,[Year] 'Year'
					,[Day] 'Day'
					,CAST([FullDate] AS DATE) 'Complete Date'
					,[WeekNo] 'Week#'
					,CASE WHEN [PublicHoliday]=1 THEN 'Yes' ELSE 'No' END as 'Public Holiday'
					,CASE WHEN [Weekend] = 1 THEN 'Yes' ELSE 'No' END as 'Weekend'
					,CASE WHEN [SalaryProcessing] = 1 THEN 'Yes' ELSE 'No' END as 'Salary Processing Date'
					,[GeneratedBy] 'Created By'
					,CAST([GeneratedDate] as DATE) 'Created Date'
				FROM [dbo].[AutoGeneratedDates]
				WHERE Active=1
				ORDER BY FullDate ASC

				EXEC [dbo].[RecordTranSummary] @AuditID,'[dbo].[AutoGeneratedDates]','Generate Data','Completed'
		END TRY

		BEGIN CATCH
			EXEC [dbo].[RecordTranSummary] @AuditID,'[dbo].[AutoGeneratedDates]','Generate Data','Error'
			RAISERROR('ERROR IN PROCESSING DATA',16,2)
		END CATCH

	END --> Auto-Generated Dates - END

	IF(@type = 102)
	BEGIN --> Auto-Generated Names - START

		BEGIN TRY
			EXEC [dbo].[RecordTranSummary] @AuditID,'[dbo].[AutoGeneratedNames]','Generate Data','Started'
	
			SELECT [RegNo] 'Registration#'
				  ,[first_name] 'First Name'
				  ,[last_name] 'Last Name'
				  ,[gender] 'Gender'
				  ,[email] 'E-Mail'
				  ,[Phone] 'Phone#'
				  ,[CreatedBy] 'Created By'
				  ,CAST([CreatedDate] AS DATE) 'Created Date'				  
			  FROM [dbo].[AutoGeneratedNames]
			  WHERE Active=1
			  ORDER BY [RegNo]

				EXEC [dbo].[RecordTranSummary] @AuditID,'[dbo].[AutoGeneratedNames]','Generate Data','Completed'
		END TRY

		BEGIN CATCH
			EXEC [dbo].[RecordTranSummary] @AuditID,'[dbo].[AutoGeneratedNames]','Generate Data','Error'
			RAISERROR('ERROR IN PROCESSING DATA',16,2)
		END CATCH

	END --> Auto-Generated Names - END

	IF(@type=103 and @AuditRefID != '')
	BEGIN
		BEGIN TRY
			EXEC [dbo].[Get_Transaction_Summary] @AuditRefID
		END TRY
		BEGIN CATCH
			EXEC [dbo].[RecordTranSummary] @AuditID,'[dbo].[TransactionSummary]','Generate Data','Error'
			RAISERROR('ERROR IN PROCESSING DATA',16,2)
		END CATCH
	END

	SET NOCOUNT OFF;
END --> SP End
GO
/****** Object:  StoredProcedure [dbo].[Report_Get_Postal_Office_Details]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:SAI BHARGAV ABBURU
-- Create date: MAR 13, 2021
-- Description: FETCH ALL OFFICE DETAILS FOR REPORT

--> EXEC [dbo].[Report_Get_Postal_Office_Details]
-- =============================================
CREATE   PROCEDURE [dbo].[Report_Get_Postal_Office_Details]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	PSL.StateName 'State',
			PCL.CircleName 'Circle Name',
			PRL.RegionName 'Region Name',
			PDL.DivisionName 'Division Name',
			PDTL.DistrictName 'District Name',
			POL.OfficeName 'Office Name',
			POT.OfficeTypeCode 'Office Type Code',
			POT.OfficeTypeName 'Office Type Name',
			PDLT.DeliveryType 'Delivery Type',
			PPL.Pincode 'Pincode',
			ROW_NUMBER()OVER(PARTITION BY POL.OfficeName, PPL.Pincode ORDER BY POL.OfficeName,PPL.Pincode) as Rowcounter
			INTO #FinalReport
	FROM	Postal_State_List PSL
			INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
			INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
			INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
			INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
			INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
			INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
			INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
			INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID
	WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
	AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1


	SELECT [STATE],[Circle Name],[Region Name],[Division Name],
	[District Name],[Office Name],[Office Type Code],[Office Type Name],[Delivery Type],[Pincode] FROM #FinalReport WHERE Rowcounter=1
	order by [Region Name],[Division Name],
	[District Name],[Office Name]

END
GO
/****** Object:  StoredProcedure [dbo].[Report_Get_Transaction_Summary]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 09, 2020
-- Description:	Fetch Transaction Summary using Audit Reference ID

--> EXEC [dbo].[Report_Get_Transaction_Summary] 'AVSSB-AUDIT-4A2B8'
-- ==================================================================
CREATE PROCEDURE [dbo].[Report_Get_Transaction_Summary] @AuditRefID NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(Select 1 FROM [dbo].[TransactionSummary] WHERE AuditRefID=@AuditRefID )
	BEGIN
		SELECT [AuditRefID] 'Audit Reference#'
			  ,[ActionOn] 'Action On'
			  ,[Action] 'Action Area'
			  ,[ActionStatus] 'Action Taken'
			  ,[GeneratedBy] 'Created By'
			  ,CAST ([GeneratedDate] AS datetime) as 'Created Date'
		  FROM [dbo].[TransactionSummary]
		  WHERE AuditRefID = @AuditRefID
		  ORDER BY GeneratedDate ASC
	 END

	 SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[Search_User_List]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 09, 2021
-- Description:	Fetch Users List

--> EXEC [dbo].[Search_User_List] 'UR-AVS-M-937216', 'email', 'ibhargav547@gmail.com'
-- =============================================
CREATE PROCEDURE [dbo].[Search_User_List] @searchBy nvarchar(100), @search nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	IF((ISNULL(@searchBy,'')='') OR (ISNULL(@search,'')=''))
	BEGIN
		SELECT TOP 10 [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 
		  ORDER BY CreatedDate DESC
	END

	IF(@searchBy = 'UserID')
	BEGIN
		SELECT [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 and UserID like '%'+@search+'%'
		  ORDER BY CreatedDate DESC
	END

	IF(@searchBy = 'firstname')
	BEGIN
		SELECT [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 and [first_name] like '%'+@search+'%'
		  ORDER BY CreatedDate DESC
	END

	IF(@searchBy = 'lastname')
	BEGIN
		SELECT [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 and [last_name] like '%'+@search+'%'
		  ORDER BY CreatedDate DESC
	END

	IF(@searchBy = 'gender')
	BEGIN
		SELECT [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 and gender like '%'+@search+'%'
		  ORDER BY CreatedDate DESC
	END

	IF(@searchBy = 'email')
	BEGIN
		SELECT [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 and [email] like '%'+@search+'%'
		  ORDER BY CreatedDate DESC
	END

	IF(@searchBy = 'Phone')
	BEGIN
		SELECT [UserID]
			  ,[first_name]
			  ,[last_name]
			  ,[gender]
			  ,[email]
			  ,[Phone]
			  ,[CreatedBy]
			  ,[CreatedDate]
		  FROM [dbo].[Users]
		  WHERE Active=1 and [Phone] like '%'+@search+'%'
		  ORDER BY CreatedDate DESC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[SearchPostalList]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author: Sai Bhargav Abburu
-- Create date: Mar 29, 2021
-- Description:	Search Postal List

--EXEC [dbo].[SearchPostalList] 'pincode', '524101'
-- =======================================================
CREATE PROCEDURE [dbo].[SearchPostalList] @searchBy nvarchar(100), @searchvalue nvarchar(100)
AS
BEGIN

	SET NOCOUNT ON;
	

	IF(@searchBy = 'pincode')
	BEGIN
		SELECT	PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName,
			POL.OfficeName,
			CONCAT(POT.OfficeTypeName,' (',POT.OfficeTypeCode,')') 'OfficeTypeName',
			PDLT.DeliveryType,
			PPL.Pincode

			FROM	Postal_State_List PSL
					INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
					INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
					INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
					INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
					INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
					INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
					INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
					INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID

			WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
			AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1 --AND PDLT.DeliveryType='Delivery'
			AND PPL.Pincode like '%'+@searchvalue+'%'

			ORDER BY 
					PSL.StateName,
					PCL.CircleName,
					PRL.RegionName,
					PDL.DivisionName,
					PDTL.DistrictName
	END

	IF(@searchBy = 'state')
	BEGIN
		SELECT	PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName,
			POL.OfficeName,
			CONCAT(POT.OfficeTypeName,' (',POT.OfficeTypeCode,')') 'OfficeTypeName',
			PDLT.DeliveryType,
			PPL.Pincode

			FROM	Postal_State_List PSL
					INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
					INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
					INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
					INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
					INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
					INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
					INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
					INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID

			WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
			AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1 --AND PDLT.DeliveryType='Delivery'
			AND PSL.StateName like '%'+@searchvalue+'%'

			ORDER BY 
					PSL.StateName,
					PCL.CircleName,
					PRL.RegionName,
					PDL.DivisionName,
					PDTL.DistrictName
	END
	
	IF(@searchBy = 'circle')
	BEGIN
		SELECT	PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName,
			POL.OfficeName,
			CONCAT(POT.OfficeTypeName,' (',POT.OfficeTypeCode,')') 'OfficeTypeName',
			PDLT.DeliveryType,
			PPL.Pincode

			FROM	Postal_State_List PSL
					INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
					INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
					INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
					INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
					INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
					INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
					INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
					INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID

			WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
			AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1 --AND PDLT.DeliveryType='Delivery'
			AND PCL.CircleName like '%'+@searchvalue+'%'

			ORDER BY 
					PSL.StateName,
					PCL.CircleName,
					PRL.RegionName,
					PDL.DivisionName,
					PDTL.DistrictName
	END

	IF(@searchBy = 'division')
	BEGIN
		SELECT	PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName,
			POL.OfficeName,
			CONCAT(POT.OfficeTypeName,' (',POT.OfficeTypeCode,')') 'OfficeTypeName',
			PDLT.DeliveryType,
			PPL.Pincode

			FROM	Postal_State_List PSL
					INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
					INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
					INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
					INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
					INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
					INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
					INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
					INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID

			WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
			AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1 --AND PDLT.DeliveryType='Delivery'
			AND PDL.DivisionName like '%'+@searchvalue+'%'

			ORDER BY 
					PSL.StateName,
					PCL.CircleName,
					PRL.RegionName,
					PDL.DivisionName,
					PDTL.DistrictName
	END

	IF(@searchBy = 'district')
	BEGIN
		SELECT	PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName,
			POL.OfficeName,
			CONCAT(POT.OfficeTypeName,' (',POT.OfficeTypeCode,')') 'OfficeTypeName',
			PDLT.DeliveryType,
			PPL.Pincode

			FROM	Postal_State_List PSL
					INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
					INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
					INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
					INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
					INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
					INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
					INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
					INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID

			WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
			AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1 --AND PDLT.DeliveryType='Delivery'
			AND PDTL.DistrictName like '%'+@searchvalue+'%'

			ORDER BY 
					PSL.StateName,
					PCL.CircleName,
					PRL.RegionName,
					PDL.DivisionName,
					PDTL.DistrictName
	END

	IF(@searchBy = 'office')
	BEGIN
		SELECT	PSL.StateName,
			PCL.CircleName,
			PRL.RegionName,
			PDL.DivisionName,
			PDTL.DistrictName,
			POL.OfficeName,
			CONCAT(POT.OfficeTypeName,' (',POT.OfficeTypeCode,')') 'OfficeTypeName',
			PDLT.DeliveryType,
			PPL.Pincode

			FROM	Postal_State_List PSL
					INNER JOIN Postal_Circle_List PCL ON PSL.StateID = PCL.StateID
					INNER JOIN Postal_Region_List PRL ON PRL.CircleID = PCL.CircleID
					INNER JOIN Postal_Division_List PDL ON PDL.RegionID = PRL.RegionID
					INNER JOIN Postal_District_List PDTL ON PDTL.DivisionID = PDL.DivisionID
					INNER JOIN Postal_Office_List POL ON POL.DistrictID = PDTL.DistrictID
					INNER JOIN Postal_Office_Type POT ON POT.OfficeTypeID = POL.OfficeTypeID
					INNER JOIN Postal_Delivery_Type PDLT ON PDLT.DeliveryID = POL.DeliveryTypeID
					INNER JOIN Postal_Pincode_List PPL ON PPL.OfficeID = POL.OfficeID

			WHERE PSL.Active=1 AND PCL.Active=1 AND PRL.Active=1 AND PDL.Active=1 AND PDTL.Active=1
			AND POL.Active=1 AND POT.Active=1 AND PDLT.Active=1 AND PPL.Active=1 --AND PDLT.DeliveryType='Delivery'
			AND POL.OfficeName like '%'+@searchvalue+'%'

			ORDER BY 
					PSL.StateName,
					PCL.CircleName,
					PRL.RegionName,
					PDL.DivisionName,
					PDTL.DistrictName
	END
END
GO
/****** Object:  StoredProcedure [dbo].[Update_User_Details]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:	Sai Bhargav Abburu
-- Create date: Mar 11, 2021
-- Description:	Update User Details 
-- 
-->PARAMETERS @UserID --> User ID whom details need to update in database.(Key Parameter)

--> EXEC [dbo].[Update_User_Details] 'UR-AVS-F-218770'
-- ==========================================================================================
CREATE PROCEDURE [dbo].[Update_User_Details] @UserID NVARCHAR(50),@first_name NVARCHAR(50),@last_name NVARCHAR(50),
@gender CHAR, @email NVARCHAR(50), @phone NVARCHAR(50)
AS
BEGIN --> SP Begin
	SET NOCOUNT ON;

	Declare @gendr NVARCHAR(10)

	IF(@gender='M')
	BEGIN
		SET @gendr='Male'
	END
	IF(@gender='F')
	BEGIN
		SET @gendr='Female'
	END
	IF(@gender='O')
	BEGIN
		SET @gendr='Others'
	END
	IF(@gender='NK')
	BEGIN
		SET @gendr='Not Known'
	END

	IF EXISTS(Select 1 From Users where UserID = @UserID)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			EXEC [dbo].[RecordTranSummary] @UserID,'[dbo].[Users]','Update User Details','User Exists'
			EXEC [dbo].[RecordTranSummary] @UserID,'[dbo].[Users]','Update User Details','Update Start'

			UPDATE Users SET first_name=@first_name,last_name=@last_name,gender=@gendr,Phone=@phone,email=@email,ModifiedBy='SYSTEM',ModifiedDate=GETDATE() 
			WHERE UserID=@UserID

			EXEC [dbo].[RecordTranSummary] @UserID,'[dbo].[Users]','Update User Details','Update Completed'

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			EXEC [dbo].[RecordTranSummary] @UserID,'[dbo].[Users]','Update User Details','Error'
			RAISERROR('Error in transaction',16,2)
		END CATCH

	END

	SET NOCOUNT ON;
END --> SP End
GO
/****** Object:  StoredProcedure [dbo].[UpdateConsignmentStatus]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sai Bhargav Abburu
-- Create date: April 4, 2021
-- Description:	Update Consignment Status
-- =============================================
CREATE PROCEDURE [dbo].[UpdateConsignmentStatus] @BookingID nvarchar(100), @Status nvarchar(100), @userid nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @sortorder int = 1

	IF EXISTS(SELECT BookingID from TrackConsignment Where BookingID = @BookingID)
	BEGIN
		SELECT @sortorder = MAX(SortOrder)+1 from TrackConsignment Where BookingID = @BookingID
	END

	Update ConsignmentDetails SET ConsignmentStatusID=@Status, StatusDate=GETDATE() Where BookingID=@BookingID


	IF NOT EXISTS (SELECT 1 FROM TrackConsignment Where BookingID=@BookingID and ConsignmentStatusID = @Status)
	BEGIN
		Insert Into [TrackConsignment] ([TrackConsignmentID],[BookingID],[ConsignmentStatusID],[StatusDateTime],[CreatedBy],[Active],[SortOrder])
		VALUES (NEWID(),@BookingID,@Status,GETDATE(),@userid,1,@sortorder)
	END
	Select 'Updated' UpdateStatus;

END
GO
/****** Object:  StoredProcedure [dbo].[UpdatePubWeekSalProcRecords]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sai Bhargav Abburu
-- Create date: Nov 24, 2020
-- Description:	Updates Public& Weekend holidays and Salary Processing Dates

--EXEC [dbo].[UpdatePubWeekSalProcRecords] 'AVSSB-AUDIT-042B6'
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePubWeekSalProcRecords] @AuditRefID nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @weekend bit
	declare @pubholiday bit
	declare @salcounter int
	declare @AutoGenID nvarchar(50)
	declare @yearcounter int
	declare @monthcounter int
	declare @whilecounteryear int
	declare @whilecountermonth int
	declare @runningyear nvarchar(50)
	declare @runningmonth nvarchar(50)
	declare @fromdate nvarchar(50)
	declare @todate nvarchar(50)
	declare @trancount int
	declare @maxdate date
	declare @weekendcounter nvarchar(20)
	declare @pubholidaycounter nvarchar(20)

	SET @weekend=1
	SET @pubholiday=1
	SET @AutoGenID=@AuditRefID
	SET @salcounter = 0

	INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
	VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Update Dates','Received','SYSTEM',GETDATE())

	TRUNCATE TABLE [dbo].[Transummary]

	CREATE TABLE #updaterec(
	[DateID] [nvarchar](50) NOT NULL,
	[Date] [int] NULL,
	[Month] [nvarchar](50) NULL,
	[Year] [nvarchar](50) NULL,
	[Day] [nvarchar](50) NULL,
	[FullDate] [datetime] NULL,
	[WeekNo] [int] NULL,
	[Active] [bit] NULL,
	[AuditRefID] [nvarchar](50) NULL,
	[PublicHoliday] [bit] NULL,
	[Weekend] [bit] NULL,
	[SalaryProcessing] [bit] NULL,
	[year_rank] [int] NULL,
	[month_rank] [int] NULL)

	INSERT INTO #updaterec
			   ([DateID]
			   ,[Date]
			   ,[Month]
			   ,[Year]
			   ,[Day]
			   ,[FullDate]
			   ,[WeekNo]
			   ,[Active]
			   ,[AuditRefID]
			   ,[PublicHoliday]
			   ,[Weekend]
			   ,[SalaryProcessing]
			   ,[year_rank]
			   ,[month_rank])
		 SELECT [DateID]
			   ,[Date]
			   ,[Month]
			   ,[Year]
			   ,[Day]
			   ,[FullDate]
			   ,[WeekNo]
			   ,[Active]
			   ,[AuditRefID]
			   ,[PublicHoliday]
			   ,[Weekend]
			   ,[SalaryProcessing]
			   ,ROW_NUMBER()OVER(PARTITION BY DATEPART(YY,FullDate) order by FullDate asc)
			   ,ROW_NUMBER()OVER(PARTITION BY DATEPART(YY,FullDate),DATEPART(MM,FullDate) order by FullDate asc)
			   from AutoGeneratedDates --where PublicHoliday != 1 and SalaryProcessing != 1 and Weekend !=  1

	CREATE TABLE #year([year] nvarchar(10),year_rank int)
	CREATE TABLE #month([month] nvarchar(10),[year] nvarchar(50),month_rank int)


	IF EXISTS (SELECT 1 from #updaterec where AuditRefID=@AuditRefID)
	BEGIN -->Weekend and Public Holiday Update Start

		INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
		VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Weekend Update','Started','SYSTEM',GETDATE())

		Update AutoGeneratedDates SET Weekend=@weekend where [Day] in ('Saturday','Sunday')
		--Set Non Weekend Holidays to '0' to avoid NULL Values in Reports
		Update AutoGeneratedDates SET Weekend=0 where Weekend IS NULL

		SELECT @weekendcounter=COUNT(1) from #updaterec where Weekend=@weekend 

		INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
		VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Weekend Update','Completed','SYSTEM',GETDATE())

		INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
		VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Holiday Update','Started','SYSTEM',GETDATE())

		Update AutoGeneratedDates SET PublicHoliday = @pubholiday where [Month]='1' and [Date]=1  --> New Year
		Update AutoGeneratedDates SET PublicHoliday = @pubholiday where [Month]='1' and [Date]=26 --> Republic Day
		Update AutoGeneratedDates SET PublicHoliday = @pubholiday where [Month]='5' and [Date]=1 --> May Day
		Update AutoGeneratedDates SET PublicHoliday = @pubholiday where [Month]='8' and [Date]=15 -->Independence Day
		Update AutoGeneratedDates SET PublicHoliday = @pubholiday where [Month]='12' and [Date]=25 --> Christmas
		--Set Non Public Holidays to '0' to avoid NULL Values in Reports
		Update AutoGeneratedDates SET PublicHoliday=0 where PublicHoliday IS NULL
		
		INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
		VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Holiday Update','Completed','SYSTEM',GETDATE())

	END -->Weekend and Public Holiday Update End

	BEGIN --> Salary Processing Date Update Start

		TRUNCATE TABLE #updaterec -->Truncate Existing records table records

		INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
		VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Salary Processing','Started','SYSTEM',GETDATE())

		BEGIN TRANSACTION
			BEGIN TRY
			-->Again insert into temp table eliminating Public, Weekend holidays for Salary Processing Date Update
				INSERT INTO #updaterec 
				   ([DateID]
				   ,[Date]
				   ,[Month]
				   ,[Year]
				   ,[Day]
				   ,[FullDate]
				   ,[WeekNo]
				   ,[Active]
				   ,[AuditRefID]
				   ,[PublicHoliday]
				   ,[Weekend]
				   ,[SalaryProcessing]
				   ,[year_rank]
				   ,[month_rank])
			 SELECT [DateID]
				   ,[Date]
				   ,[Month]
				   ,[Year]
				   ,[Day]
				   ,[FullDate]
				   ,[WeekNo]
				   ,[Active]
				   ,[AuditRefID]
				   ,[PublicHoliday]
				   ,[Weekend]
				   ,[SalaryProcessing]
				   ,ROW_NUMBER()OVER(PARTITION by DATEPART(YY,FullDate) order by FullDate asc)
				   ,ROW_NUMBER()OVER(PARTITION by DATEPART(YY,FullDate),DATEPART(MM,FullDate) order by FullDate asc)
				   from AutoGeneratedDates where PublicHoliday = 0 and Weekend = 0

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Salary Processing','Running','SYSTEM',GETDATE())

				--Update #updaterec SET SalaryProcessing=1 where month_rank=1

				Update AutoGeneratedDates Set SalaryProcessing = 1 where DateID in (Select DateID from #updaterec where month_rank=1)
				--Set Non Salary Processing to '0' to avoid NULL Values in Reports
				Update AutoGeneratedDates SET SalaryProcessing=0 where SalaryProcessing IS NULL
				
				COMMIT TRANSACTION

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Salary Processing','Completed','SYSTEM',GETDATE())

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Update Dates','Delivered','SYSTEM',GETDATE())

			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION

				INSERT INTO [dbo].[TransactionSummary]([TranSumryID],[AuditRefID],[ActionOn],[Action],[ActionStatus],[GeneratedBy],[GeneratedDate])
				VALUES (NEWID(),@AutoGenID,'[dbo].[AutoGeneratedDates]','Auto Generate Dates - Salary Processing','Error','SYSTEM',GETDATE())

			END CATCH
	END --> Salary Processing Date Update End
	
	DROP TABLE #month
	DROP TABLE #year
	DROP TABLE #updaterec
	
	--SELECT Tranname as 'Transaction Name',TranCount as 'Transaction Count' from Transummary
END
SET NOCOUNT OFF;
GO
/****** Object:  StoredProcedure [dbo].[User_Login_Auth]    Script Date: 5/21/2021 7:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: SAI BHARGAV ABBURU
-- Create date:MAR 13, 2021
-- Description:	User Login authentication

--EXEC User_Login_Auth 'UR-AVS-M-937216','GK@8073'
-- =============================================
CREATE PROCEDURE [dbo].[User_Login_Auth] @userid nvarchar(50), @pwd nvarchar(50)
AS
BEGIN

	CREATE TABLE #userauth(UserID nvarchar(100), [Password] nvarchar(100))

	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM Users WHERE UserID=@userid AND Active=1)
	BEGIN
		IF((SELECT 1 FROM Login_Credentials WHERE [Password]=@pwd and Credentials_Ref_ID = (Select Credentails_Ref_Id from Users where UserID=@userid))=1)
		BEGIN
			SELECT U.UserID 'UserID', LC.Password 'Password'  FROM Users U 
			INNER JOIN Login_Credentials LC
			ON U.Credentails_Ref_Id = LC.Credentials_Ref_ID
			WHERE U.UserID=@userid AND LC.Password=@pwd AND Active=1
		END
		ELSE
		BEGIN
			SELECT @userid [UserID],'' [Password]
		END
	END
	ELSE
	BEGIN
		SELECT '' [UserID],'' [Password]
	END
	
END
GO
USE [master]
GO
ALTER DATABASE [TestDatabase] SET  READ_WRITE 
GO
