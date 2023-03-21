USE [xpertloc]
GO
/****** Object:  StoredProcedure [dbo].[LMS_GetBeaconData]    Script Date: 3/21/2023 7:59:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DAVID HOEFS
-- Create date: 12-13-2022
-- Description:	Gets the lot beacon data
-- =============================================
ALTER PROCEDURE [dbo].[LMS_GetBeaconData]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT libd.Beacon AS BeaconName,
           libd.Host AS ReaderName,
           libd.LastDT,
           libd.Distance,
           libd.rssi,
           libd.BeaconDataId AS Id,
		   lfrl.X,
		   lfrl.Y
	FROM dbo.LMS_BeaconData libd
	INNER JOIN dbo.LMS_FabReaderLocations lfrl ON lfrl.ReaderName = libd.Host
	ORDER BY libd.LastDT DESC
END
