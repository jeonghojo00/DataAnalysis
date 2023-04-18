-- Showing Top 3 
SELECT TOP 3 *
FROM NashVilleHousingData;

-- 1. Preprocess NULL values
--- Showing Rows with NULL values in column PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a 
JOIN NashvilleHousingData b 
    ON a.ParcelID = b.ParcelID 
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a 
JOIN NashvilleHousingData b 
    ON a.ParcelID = b.ParcelID 
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--- Check if PropertyAddress column contains NULL values anymore
SELECT *
FROM NashvilleHousingData
WHERE PropertyAddress IS NULL

-- 2. Break out Address into individual columns (address, city, state)
--- Check address columns to process
SELECT TOP 3 PropertyAddress, OwnerAddress
FROM NashvilleHousingData

-- Divide PropertyAddress column into address and city
-- Apply LTRIM and RTRIM to get rid off leading and trailing spaces after removal of ','
SELECT 
   LTRIM(RTRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress) -1))) AS address,
   LTRIM(RTRIM(SUBSTRING(PropertyAddress, CHARINDEX(', ', PropertyAddress)+1, LEN(PropertyAddress)))) AS city
FROM NashvilleHousingData;

--- Add address and city columns for PropertyAddress
ALTER TABLE NashvilleHousingData
ADD PropertyAddress_address NVARCHAR(50);

ALTER TABLE NashvilleHousingData
ADD PropertyAddress_city NVARCHAR(50);

--- Update property address and city columns by applying SUBSTRING
UPDATE NashvilleHousingData
SET PropertyAddress_address = 
    LTRIM(
        RTRIM(
            SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
        )
    );

UPDATE NashvilleHousingData
SET PropertyAddress_city = 
    LTRIM(
        RTRIM(
            SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
        )
    );

--- Breakd down OwnerAddress by using PARSENAME and REPLACE
SELECT TOP 3 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingData;

--- ADD address, city, and state columns for OwnerAddress
ALTER TABLE NashvilleHousingData
ADD OwnerAddress_address NVARCHAR(50);

ALTER TABLE NashvilleHousingData
ADD OwnerAddress_city NVARCHAR(50);

ALTER TABLE NashvilleHousingData
ADD OwnerAddress_state NVARCHAR(50);

--- Update newly created columns
UPDATE NashvilleHousingData
SET OwnerAddress_address = LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)));

UPDATE NashvilleHousingData
SET OwnerAddress_city = LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)));

UPDATE NashvilleHousingData
SET OwnerAddress_state = LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)));

-- 3. Change Y and N to Yes and No in "SoldAsVacent" column
--- Count SoladAsVacant column if values are consistent
SELECT SoldAsVacant, COUNT(*) AS Occurrences
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY Occurrences DESC;

--- Convert Y to Yes and N to No
SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' Then 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacant_converted
FROM NashvilleHousingData

--- Update SoldAsVacdnt as above
Update NashvilleHousingData
SET SoldAsVacant =
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' Then 'No'
        ELSE SoldAsVacant
    END

-- 4. Remove Duplicates
--- Delete rows with duplicate values over columns
WITH RowNumCTE AS (
SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY 
            ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
        ORDER BY UniqueID) row_num
FROM NashvilleHousingData
)

DELETE
FROM RowNumCTE
WHERE row_num > 1;

--- Check if duplicates are removed
WITH RowNumCTE AS (
SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY 
            ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
        ORDER BY UniqueID) row_num
FROM NashvilleHousingData
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;

-- 5. Delete Unused Columns
--- Make a temporary table to work on
SELECT *
INTO #NashVilleHousingData
FROM NashVilleHousingData;

--- Drop columns that are redundant
ALTER TABLE #NashVilleHousingData
DROP COLUMN PropertyAddress, OwnerAddress;