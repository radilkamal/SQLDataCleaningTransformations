--------DATA CLEANING USING SQL---------

--Important to clean the data to make it more useable in the future. 
--Will not actually delete everything as you usually would, in order to follow the queries in the future


select * from [dbo].[NashvilleHousing]

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standarize Date Fomat
update nashvillehousing 
set saledate= convert(date,saledate)

alter table nashvillehousing
add SaleDateCoverted date;

update Nashvillehousing
set SaleDateCoverted = convert(date, saledate)

select SaleDateCoverted from [dbo].[NashvilleHousing]

--can remove saledate if you wish

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
select * from [dbo].[NashvilleHousing]
where propertyaddress is NULL
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b 
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b 
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid





------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual coloumns (Address, City, State)  

select 
SUBSTRING (propertyaddress, 1, CHARINDEX(',',  PropertyAddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) as  FollowingAddress
from [dbo].[NashvilleHousing]


alter table Nashvillehousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING (propertyaddress, 1, CHARINDEX(',',  PropertyAddress)-1) 


alter table Nashvillehousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))



-- now need to split the owneraddress column (through parsename) --
select owneraddress from NashvilleHousing
select * from NashvilleHousing


select 
PARSENAME(replace(owneraddress,',','.'), 3) ,
PARSENAME(replace(owneraddress,',','.'), 2) ,
PARSENAME(replace(owneraddress,',','.'), 1)
from NashvilleHousing



alter table Nashvillehousing
add OwnersplitAddress nvarchar(255)

update NashvilleHousing
set OwnersplitAddress = PARSENAME(replace(owneraddress,',','.'), 3)



alter table Nashvillehousing
add OwnersplitCity nvarchar(255)

update NashvilleHousing
set OwnersplitCity = PARSENAME(replace(owneraddress,',','.'), 2)




alter table Nashvillehousing
add OwnersplitCyState nvarchar(255)

update NashvilleHousing
set OwnersplitCyState = PARSENAME(replace(owneraddress,',','.'), 1)



------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant) from NashvilleHousing

Select SoldAsVacant
, CASE when soldasvacant = 'Y' THEN 'YES'
       when soldasvacant = 'N' then 'NO'
       else SoldAsVacant 
       end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when soldasvacant = 'Y' THEN 'YES'
       when soldasvacant = 'N' then 'NO'
       else SoldAsVacant 
       end


------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates (not good to remove the data for good usually but I will be for this)
with RowNumCTE as (
select *, ROW_NUMBER() over(
partition by parcelid,
			 propertyaddress, 
		     saleprice, 
			 saledate, 
			 legalreference
			 order by 
			 uniqueid) 
			 as rownum

from NashvilleHousing
)
delete from RowNumCTE where rownum > 1



with RowNumCTE as (
select *, ROW_NUMBER() over(
partition by parcelid,
			 propertyaddress, 
		     saleprice, 
			 saledate, 
			 legalreference
			 order by 
			 uniqueid) 
			 as rownum

from NashvilleHousing
)
select * from RowNumCTE where rownum > 1


------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns


select * from NashvilleHousing


alter table NashvilleHousing
drop column taxdistrict -- and whatever else




