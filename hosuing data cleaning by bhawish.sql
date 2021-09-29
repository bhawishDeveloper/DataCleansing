

select * from nashvilleHousing..housing

--standardize date format
select SaleDate, CONVERT(date, SaleDate) 
from nashvilleHousing..housing

alter table nashvilleHousing..housing
add salesDate Date;

update nashvilleHousing..housing
set salesDate = CONVERT(date, SaleDate);

select salesDate, CONVERT(date, SaleDate) 
from nashvilleHousing..housing


---populate property address data
select *
from nashvilleHousing..housing
where PropertyAddress is null


---many of rows parcelId's are same where as their propertyAddress are also same
select *
from nashvilleHousing..housing
--order by ParcelID
--where PropertyAddress is null

-- so in this case we can do one thing we can join rows like if ParcelId of row1 = ParcelId of row 2 than
-- we can do PropertyAddress of row1 = PropertyAddress of row2 
select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashvilleHousing..housing a
join nashvilleHousing..housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashvilleHousing..housing a
JOIN nashvilleHousing..housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


---breaking address into individual columns (address, city, state)
-- we have split address , now update it in original table
select PropertyAddress
from nashvilleHousing..housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From nashvilleHousing..housing


ALTER TABLE nashvilleHousing..housing
Add PropertySplitAddress Nvarchar(255);

Update nashvilleHousing..housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashvilleHousing..housing
Add PropertySplitCity Nvarchar(255);

Update nashvilleHousing..housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From nashvilleHousing..housing




--- now do same thing for owner address but in another way
Select OwnerAddress
From nashvilleHousing..housing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashvilleHousing..housing



ALTER TABLE nashvilleHousing..housing
Add OwnerSplitAddress Nvarchar(255);

Update nashvilleHousing..housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE nashvilleHousing..housing
Add OwnerSplitCity Nvarchar(255);

Update nashvilleHousing..housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE nashvilleHousing..housing
Add OwnerSplitState Nvarchar(255);

Update nashvilleHousing..housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From nashvilleHousing..housing



-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvilleHousing..housing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashvilleHousing..housing


Update nashvilleHousing..housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) row_num
From nashvilleHousing..housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From nashvilleHousing..housing





-- Delete Unused Columns
Select *
From nashvilleHousing..housing


ALTER TABLE nashvilleHousing..housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 