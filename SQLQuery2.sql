select *
from portfoilio_project..NashvilleHousing

----------------------- standardization of date

select SaleDate, CONVERT(date,SaleDate)
from portfoilio_project..NashvilleHousing

alter table NashvilleHousing
add datechanged date;

update NashvilleHousing
set datechanged = CONVERT(date,SaleDate)

select datechanged 
from portfoilio_project..NashvilleHousing

----------------------- Property address data

select PropertyAddress 
from portfoilio_project..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
from portfoilio_project..NashvilleHousing A
join portfoilio_project..NashvilleHousing B
  on A.ParcelID = B.ParcelID
  and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from portfoilio_project..NashvilleHousing A
join portfoilio_project..NashvilleHousing B
  on A.ParcelID = B.ParcelID
  and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

----------------------- Breaking out address into individual coloumns (Address, City, State)

select PropertyAddress
from portfoilio_project..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from portfoilio_project..NashvilleHousing


alter table NashvilleHousing
add Splitaddress nvarchar(255);

update NashvilleHousing
set Splitaddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


alter table NashvilleHousing
add cityname nvarchar(255);

update NashvilleHousing
set cityname = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


select PropertyAddress -- different approach. we can use Parsename instead of substring andthen alter and update the table.
from portfoilio_project..NashvilleHousing

select 
PARSENAME(replace(PropertyAddress,',','.'),2),
PARSENAME(replace(PropertyAddress,',','.'),1)
from portfoilio_project..NashvilleHousing

----------------------- change Y and N to yes and no in "Sold and vacant" field.

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from portfoilio_project..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from portfoilio_project..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from portfoilio_project..NashvilleHousing

----------------------- Deleting Duplicate rows from the table. we use partition by and cte as well.

with row_numCTE as(
select *, 
          ROW_NUMBER() over (
          partition by ParcelID,PropertyAddress,SalePrice,SalePrice,LegalReference
		  order by UniqueID
           ) as row_num
from portfoilio_project..NashvilleHousing
)

delete
from row_numCTE
where row_num > 1

----------------------- Delete unused columns or useless columns

select *
from portfoilio_project..NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress, SaleDate




