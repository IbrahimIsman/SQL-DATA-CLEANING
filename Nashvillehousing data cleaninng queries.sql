CREATE TABLE IF NOT EXISTS property_data(
	UniqueID INT,	
    ParcelID VARCHAR,	
    LandUse	VARCHAR,
	PropertyAddress	VARCHAR,
	SaleDate VARCHAR,	
	SalePrice INT,	
	LegalReference VARCHAR,	
	SoldAsVacant VARCHAR,	
	OwnerName VARCHAR,	
	OwnerAddress VARCHAR,	
	Acreage FLOAT,
	TaxDistrict VARCHAR,	
	LandValue INT,	
	BuildingValue INT,	
	TotalValue INT,	
	YearBuilt INT,
	Bedrooms INT,	
	FullBath INT,	
	HalfBath INT
	)

ALTER TABLE property_data
ALTER COLUMN saleprice TYPE VARCHAR;

/*Imported data from excel at this point*/

/*format date type to standard*/

ALTER TABLE property_data
ALTER COLUMN saledate TYPE date
USING saledate::date;

/* filling out ull address based on parcel id, where parcelids are the same but the adreess is null for some reasono*/

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, 
coalesce(a.propertyaddress, b.propertyaddress)
from property_data a
join property_data b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


update property_data  
set propertyaddress =  coalesce(a.propertyaddress, b.propertyaddress)
from property_data a
join property_data b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

select * from property_data where propertyaddress is null

/* splitting address into seperate columns, street and city and then dropping unnecessary version*/

select 
substring(propertyaddress, 1, strpos(propertyaddress, ',') -1) as address,
substring(propertyaddress, strpos(propertyaddress, ',') +1, length(propertyaddress)) as address
from property_data

ALTER TABLE property_data
add COLUMN address VARCHAR;

UPDATE property_data
SET address = substring(propertyaddress, 1, strpos(propertyaddress, ',') -1)

ALTER TABLE property_data
ADD COLUMN city VARCHAR

UPDATE property_data
SET city = substring(propertyaddress, strpos(propertyaddress, ',') +1, length(propertyaddress))

ALTER TABLE property_data
DROP COLUMN propertyaddress


/* sold as vacant fiedl has some y, n ,yes 7 no , lets standardaise this*/

select distinct (soldasvacant), count(soldasvacant)
from property_data
group by (soldasvacant)
order by 2

/* since yes and no are more common we will switch y & n to them */

SELECT  
 CASE 
 	  WHEN soldasvacant = 'Y' THEN 'Yes' 
 	  WHEN soldasvacant = 'N' THEN 'No'
	  ELSE soldasvacant
	  END
FROM property_data

UPDATE property_data
SET soldasvacant = 
 	CASE WHEN soldasvacant = 'Y' THEN 'Yes' 
 	  	 WHEN soldasvacant = 'N' THEN 'No'
	  	 ELSE soldasvacant
	     END

/* Removing unnecessary data columns like tax districk */

ALTER TABLE property_data
DROP COLUMN taxdistrict






