SELECT *
FROM NashvellHousing..Housing

--Working on the SaleDate
SELECT SaleDate
FROM NashvellHousing..Housing

ALTER TABLE NashvellHousing..Housing
ADD MainSaleDate Date;
UPDATE NashvellHousing..Housing
SET MainSaleDate = CAST(SaleDate AS Date)

--Working on PropertyAddress
SELECT PropertyAddress
FROM NashvellHousing..Housing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvellHousing..Housing a
JOIN NashvellHousing..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvellHousing..Housing a
JOIN NashvellHousing..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out the address
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvellHousing..Housing

ALTER TABLE NashvellHousing..Housing
ADD PropertyAdressSplit Nvarchar(255);
UPDATE NashvellHousing..Housing
SET PropertyAdressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvellHousing..Housing
ADD PropertyCitySplit Nvarchar(255);
UPDATE NashvellHousing..Housing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Working on OwnerAddress
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS TheAdress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS TheCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS TheState
FROM NashvellHousing..Housing

ALTER TABLE NashvellHousing..Housing
ADD OwnerAddressSplit Nvarchar(255);
UPDATE NashvellHousing..Housing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvellHousing..Housing
ADD OwnerCitySplit Nvarchar(255);
UPDATE NashvellHousing..Housing
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvellHousing..Housing
ADD OwnerStateSplit Nvarchar(255);
UPDATE NashvellHousing..Housing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Working on SoldAsVacant (This Y,N thing)
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvellHousing..Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvellHousing..Housing

UPDATE NashvellHousing..Housing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Working on Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	ORDER BY UniqueID) row_num
FROM NashvellHousing..Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETE 
--FROM RowNumCTE
--WHERE row_num > 1

--Deleting unused columns
ALTER TABLE NashvellHousing..Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate