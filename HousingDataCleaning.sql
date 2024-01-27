--------DATA CLEANING USING SQL---------
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







------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field






------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates






------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns