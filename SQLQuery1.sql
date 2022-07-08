--CLEANING DATA IN SQL

select * 
from portfolioproject.dbo.NAVSH$

--Standardize Date Format

select SaleDate, convert(date,SaleDate)
from portfolioproject.dbo.NAVSH$
Update portfolioproject.dbo.NAVSH$
SET SaleDate = Convert(date,SaleDate)

--populate property adress data

select PropertyAddress
from portfolioproject.dbo.NAVSH$
where PropertyAddress is null 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NAVSH$ a
JOIN PortfolioProject.dbo.NAVSH$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NAVSH$ a
JOIN PortfolioProject.dbo.NAVSH$ b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',' , PropertyAddress) -1) as Adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NAVSH$ a


ALTER TABLE PortfolioProject.dbo.NAVSH$
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NAVSH$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NAVSH$
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NAVSH$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProject.dbo.NAVSH$


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

From PortfolioProject.dbo.NAVSH$

ALTER TABLE PortfolioProject.dbo.NAVSH$
add OwnerSplitAddress Nvarchar(255);

update PortfolioProject.dbo.NAVSH$
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NAVSH$
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NAVSH$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NAVSH$

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From  PortfolioProject.dbo.NAVSH$
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From  PortfolioProject.dbo.NAVSH$

Update PortfolioProject.dbo.NAVSH$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--remove duplicates
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

From PortfolioProject.dbo.NAVSH$

)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select *
From PortfolioProject.dbo.NAVSH$


ALTER TABLE PortfolioProject.dbo.NAVSH$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

