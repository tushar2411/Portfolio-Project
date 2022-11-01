--Cleaning Data In SQL

Select * from Portfolio_Project.dbo.NashvilleJousing



-- Standardize Date Format

Select SaleDate
from Portfolio_Project.dbo.NashvilleJousing

Select SaleDateConverted, CONVERT(Date,SaleDate)
from Portfolio_Project.dbo.NashvilleJousing

Update NashvilleJousing
SET SaleDate = CONVERT(Date,SaleDate)



-- If it doesn't Update properly

Alter Table NashvilleJousing
Add SaleDateConverted Date;

Update NashvilleJousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 




-- Poppulate Property Address Data

Select *
from Portfolio_Project.dbo.NashvilleJousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleJousing a
JOIN Portfolio_Project.dbo.NashvilleJousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleJousing a
JOIN Portfolio_Project.dbo.NashvilleJousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null





-- Breaking out Address into individual Columns (City,Address,State)

Select PropertyAddress
from Portfolio_Project.dbo.NashvilleJousing
--Where PropertyAddress is null
--Order By ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

from Portfolio_Project.dbo.NashvilleJousing

ALTER TABLE Portfolio_Project.dbo.NashvilleJousing
Add PropertySplitAddress Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleJousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Portfolio_Project.dbo.NashvilleJousing
Add PropertySplitCity Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleJousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select * from Portfolio_Project.dbo.NashvilleJousing

Select OwnerAddress from Portfolio_Project.dbo.NashvilleJousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Portfolio_Project.dbo.NashvilleJousing

ALTER TABLE Portfolio_Project.dbo.NashvilleJousing DROP COLUMN OwnerSplitAddress, OwnerSplitCity

ALTER TABLE Portfolio_Project.dbo.NashvilleJousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleJousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Portfolio_Project.dbo.NashvilleJousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleJousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Portfolio_Project.dbo.NashvilleJousing
Add OwnerSplitState Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleJousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Portfolio_Project.dbo.NashvilleJousing


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleJousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From Portfolio_Project.dbo.NashvilleJousing

Update Portfolio_Project.dbo.NashvilleJousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

Select * From Portfolio_Project.dbo.NashvilleJousing



--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio_Project.dbo.NashvilleJousing
--order by ParcelID
)
SELECT * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From Portfolio_Project.dbo.NashvilleJousing



--Delete Unused Columns

Select * from Portfolio_Project.dbo.NashvilleJousing

Alter Table Portfolio_Project.dbo.NashvilleJousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

