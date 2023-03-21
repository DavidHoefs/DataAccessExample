USE [xpertloc]
GO
/****** Object:  StoredProcedure [dbo].[LMS_BeaconDataEdit]    Script Date: 3/20/2023 5:39:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===============================================================
--Author: Roy D Smith
--Description: Collect Beacon Data for Location Management System
--2022-12-08: Created
--2023-01-09: Standardized.  ~bka
--2023-02-27: Updates logic to insert new records when Rssi value is +- 2 away from previous record ~dhoefs
--===============================================================
ALTER PROCEDURE [dbo].[LMS_BeaconDataEdit]
    @Beacon VARCHAR(50),
    @Host VARCHAR(50),
    @Distance VARCHAR(50),
    @Rssi VARCHAR(50)
AS
BEGIN
    --RETURN 0
    BEGIN TRY
		
        DECLARE @Employee INT,
                @Error INT,
                @RetVal INT,
                @TransDate DATETIME,
                @TranStarted BIT,
                @XpertSoftwareErrorLogId INT,
                @XpertSoftwareId INT,
                @NewRssi INT,
                @LastRssi INT,
                @UpperLimit INT,
                @LowerLimit INT,
                @LastId INT;
        --BEGIN
        IF (@@TRANCOUNT = 0)
        BEGIN
            BEGIN TRANSACTION;
            SET @TranStarted = 1;
        END;
        ELSE BEGIN
			SET @TranStarted = 0;
        END;
        --Set Parameters
        BEGIN
            SET NOCOUNT ON;
            SET @Employee = -1;
            SET @TransDate = GETDATE();
            SET @XpertSoftwareId = 19;
        END;

		-- If Rssi = -127 (Max Value), do not insert (This means the beacon is really far away from a reader)
        IF (@Rssi = '-127') GOTO Final;

        SET @NewRssi = CAST(@Rssi AS INT);

        -- Get the most recent Rssi value for the given Beacon/Host combo and its ID
        BEGIN
            SELECT TOP (1)
                   @LastRssi = CAST(Rssi AS INT),
                   @LastId = lbd.BeaconDataId
            FROM dbo.LMS_BeaconData lbd
            WHERE Beacon = @Beacon
                  AND Host = @Host
            ORDER BY LastDt DESC;
        END;

        -- Set upper and lower limits
        BEGIN
            SET @UpperLimit = @LastRssi - 2;
            SET @LowerLimit = @LastRssi + 2;
        END;

        --BEGIN
        --    -- IF the new Rssi value is +- 2 from the previous, update the previous record
        --    IF (@NewRssi BETWEEN @UpperLimit AND @LowerLimit)
        --    BEGIN
        --        UPDATE dbo.LMS_BeaconData
        --        SET LastDt = @TransDate,
        --            Distance = @Distance,
        --            Rssi = @Rssi
        --        WHERE BeaconDataId = @LastId;

        --        SELECT @Error = @@ERROR;

        --        IF (@Error <> 0)
        --        BEGIN
        --            SET @RetVal = 99;
        --            GOTO Failed;
        --        END;
        --    END;
        --    -- Else insert a new record
        --    ELSE
        --    BEGIN
        --        INSERT INTO dbo.LMS_BeaconData
        --        (
        --            Beacon,
        --            Host,
        --            LastDt,
        --            Distance,
        --            Rssi
        --        )
        --        VALUES
        --        (@Beacon, @Host, @TransDate, @Distance, @Rssi);

        --        SELECT @Error = @@ERROR;

        --        IF (@Error <> 0)
        --        BEGIN
        --            SET @RetVal = 99;
        --            GOTO Failed;
        --        END;
        --    END;
        --END;
        --Update Database
        BEGIN
            IF (EXISTS
            (
                SELECT 1
                FROM dbo.LMS_BeaconData
                WHERE Beacon = @Beacon
                      AND Host = @Host
            )
               )
            BEGIN

                UPDATE dbo.LMS_BeaconData
                SET LastDt = @TransDate,
                    Distance = @Distance,
                    Rssi = @Rssi
                WHERE Beacon = @Beacon
                      AND Host = @Host;

                SELECT @Error = @@ERROR;

                IF (@Error <> 0)
                BEGIN
                    SET @RetVal = 99;
                    GOTO Failed;
                END;
            END;
            ELSE
            BEGIN
                INSERT INTO dbo.LMS_BeaconData
                (
                    Beacon,
                    Host,
                    LastDt,
                    Distance,
                    Rssi
                )
                VALUES
                (@Beacon, @Host, @TransDate, @Distance, @Rssi);

                SELECT @Error = @@ERROR;

                IF (@Error <> 0)
                BEGIN
                    SET @RetVal = 99;
                    GOTO Failed;
                END;
            END;
        END;

        Final:
        --Finalize
        IF (@TranStarted = 1)
        BEGIN
            IF (@@ERROR = 0)
            BEGIN
                SET @TranStarted = 0;
                COMMIT TRANSACTION;
            END;
            ELSE BEGIN
				SET @TranStarted = 0;
				ROLLBACK TRANSACTION;
            END;
        END;
        RETURN 0;

        Failed:
        --Rollback Transaction if Started
        IF (@TranStarted = 1)
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        --Record Error
        BEGIN
            EXEC dbo.SYS_XpertSoftwareErrorLogAdd_r1 @XpertSoftwareId = @XpertSoftwareId,
                                                     @ErrorCode = @RetVal, --Xpert Software Error Code
                                                     @Employee = @Employee,
                                                     @TransDate = @TransDate,
                                                     @TransactionId = '-1',
                                                     @Comment = '',
                                                     @DatabaseError = -1,
                                                     @XpertSoftwareErrorLogId = @XpertSoftwareErrorLogId OUTPUT;

        END;
        RETURN @RetVal;
    END TRY
    BEGIN CATCH
        --Rollback Transaction if Exists
        IF (@TranStarted = 1)
        BEGIN
            SET @TranStarted = 0;
            ROLLBACK TRANSACTION;
        END;
        --Declare Error Parameters
        BEGIN
            DECLARE @ErrorComment VARCHAR(MAX),
                    @ErrorLine INT,
                    @ErrorMessage VARCHAR(MAX),
                    @ErrorNumber INT,
                    @ErrorProcedure VARCHAR(MAX);
        END;
        --Get Error Parameters
        BEGIN
            SELECT @ErrorMessage = ERROR_MESSAGE(),
                   @ErrorNumber = ERROR_NUMBER(),
                   @ErrorLine = ERROR_LINE(),
                   @ErrorProcedure = ERROR_PROCEDURE();
        END;
        --Set Error Comment
        SET @ErrorComment
            = 'MSG: ' + @ErrorMessage + ', Proc: ' + @ErrorProcedure + ', Line No:' + LTRIM(STR(@ErrorLine));
        --Record Error
        BEGIN
            EXEC dbo.SYS_XpertSoftwareErrorLogAdd_r1 @XpertSoftwareId = @XpertSoftwareId,
                                                     @ErrorCode = 9915, --Xpert Software Error Code
                                                     @Employee = @Employee,
                                                     @TransDate = @TransDate,
                                                     @TransactionId = '-1',
                                                     @Comment = @ErrorComment,
                                                     @DatabaseError = @ErrorNumber,
                                                     @XpertSoftwareErrorLogId = @XpertSoftwareErrorLogId OUTPUT;
        END;
        --Return Generic Database Error Code
        RETURN 9915;
    END CATCH;
END;