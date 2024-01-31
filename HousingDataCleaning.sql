--------DATA CLEANING USING SQL--------

-- Important to clean the data to make it more usable in the future.
-- Will not actually delete everything as you usually would, in order to follow the queries in the future

-- Retrieve all columns from [dbo].[NashvilleHousing]
SELECT * FROM [dbo].[NashvilleHousing];

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
UPDATE NashvilleHousing 
SET saledate = CONVERT(DATE, saledate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE Nashvillehousing
SET SaleDateConverted = CONVERT(DATE, saledate);

SELECT SaleDateConverted FROM [dbo].[NashvilleHousing];

-- Can remove saledate if you wish

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
SELECT * FROM [dbo].[NashvilleHousing]
WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b 
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b 
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual columns (Address, City, State)  
SELECT 
    SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) AS FollowingAddress
FROM [dbo].[NashvilleHousing];

ALTER TABLE Nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE Nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress));

-- Now need to split the owneraddress column (through parsename) --
SELECT owneraddress FROM NashvilleHousing;

SELECT * FROM NashvilleHousing;

SELECT 
    PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
    PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
    PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
FROM NashvilleHousing;

ALTER TABLE Nashvillehousing
ADD OwnersplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnersplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3);

ALTER TABLE Nashvillehousing
ADD OwnersplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnersplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2);

ALTER TABLE Nashvillehousing
ADD OwnersplitCyState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnersplitCyState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1);

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant) FROM NashvilleHousing;

SELECT 
    SoldAsVacant,
    CASE 
        WHEN soldasvacant = 'Y' THEN 'YES'
        WHEN soldasvacant = 'N' THEN 'NO'
        ELSE SoldAsVacant 
    END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
    WHEN soldasvacant = 'Y' THEN 'YES'
    WHEN soldasvacant = 'N' THEN 'NO'
    ELSE SoldAsVacant 
    END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates (not good to remove the data for good usually but I will be for this)
WITH RowNumCTE AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY parcelid,
        propertyaddress, 
        saleprice, 
        saledate, 
        legalreference
        ORDER BY 
        uniqueid
    ) AS rownum
    FROM NashvilleHousing
)
DELETE FROM RowNumCTE WHERE rownum > 1;

WITH RowNumCTE AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY parcelid,
        propertyaddress, 
        saleprice, 
        saledate, 
        legalreference
        ORDER BY 
        uniqueid
    ) AS rownum
    FROM NashvilleHousing
)
SELECT * FROM RowNumCTE WHERE rownum > 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
SELECT * FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN taxdistrict; -- and whatever else
