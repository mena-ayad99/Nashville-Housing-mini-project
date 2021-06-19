-- Exploring Nashville Housing data

SELECT *
FROM PortfolioProjects..NashvilleHousing



-- Standardizing sale date and converting to date format

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate date
SELECT *
FROM PortfolioProjects..NashvilleHousing



-- Exploirng and populating NULL values (29) in property address with self-merge using PercelID

SELECT *
FROM PortfolioProjects..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT *
FROM PortfolioProjects..NashvilleHousing
WHERE PropertyAddress IS NULL



--Breaking property address into multiple columns

SELECT PropertyAddress, OwnerAddress
FROM PortfolioProjects..NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS property_address,
	SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) AS property_city
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD property_address NVARCHAR(255);

UPDATE NashvilleHousing
SET property_address = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD property_city NVARCHAR(255);

UPDATE NashvilleHousing
SET property_city = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProjects..NashvilleHousing



--Breaking owner address into multiple columns

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) AS Owner_address,
	PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) AS Owner_city,
		PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) AS Owner_state
FROM PortfolioProjects..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD Owner_address NVARCHAR(255);

UPDATE NashvilleHousing
SET Owner_address = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD Owner_city NVARCHAR(255);

UPDATE NashvilleHousing
SET Owner_city = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD Owner_state NVARCHAR(255);

UPDATE NashvilleHousing
SET Owner_state = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

SELECT *
FROM PortfolioProjects..NashvilleHousing



--Standardizing data entries in SoldAsVacant column

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant



--Finding and deleting deplicate data entries

	-- identifying deplicates 
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
		ORDER BY UniqueID) AS row_num
FROM PortfolioProjects..NashvilleHousing
ORDER BY ParcelID

WITH RownumCTE AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
		ORDER BY UniqueID) AS row_num
FROM PortfolioProjects..NashvilleHousing
)


--DELETE 
--FROM RownumCTE
--WHERE row_num > 1

SELECT *
FROM RownumCTE
WHERE row_num > 1




