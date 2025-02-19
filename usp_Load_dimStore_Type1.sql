CREATE PROCEDURE usp_Load_dimStore
AS
BEGIN
    -- Upsert logic for Type 1 dimensions.
    -- Matches the StoreName field between the staging table [stage].[Store] and the target table [dbo].[dimStore].

    MERGE [dbo].[dimStore] AS Target
    USING (
        SELECT 
            StoreName, 
            StoreType, 
            Description
        FROM 
            [stage].[Store]
    ) AS Source
    ON Target.StoreName = Source.StoreName -- Match condition on StoreName
    WHEN MATCHED THEN
        -- Update existing records in the target table
        UPDATE SET 
            Target.StoreType = Source.StoreType, 
            Target.Description = Source.Description,
            Target.UpdatedDate = GETDATE()
    WHEN NOT MATCHED THEN
        -- Insert new records into the target table
        INSERT (StoreName, StoreType, Description, InsertedDate, UpdatedDate) 
        VALUES (Source.StoreName, Source.StoreType, Source.Description, GETDATE(), GETDATE());

END