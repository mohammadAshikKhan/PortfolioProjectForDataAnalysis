--DATABASE NAME
USE PortfolioProjects


SELECT TOP 1000 *
FROM [Nashville_Housing ]


-- Standardize Date Format
SELECT SaleDate
FROM [Nashville_Housing ]

ALTER TABLE [Nashville_Housing ]
ADD SaleDateConverted DATE;

UPDATE [Nashville_Housing ]
SET SaleDateConverted  = CONVERT(DATE, SaleDate);


-- Populate Property Address data
SELECT *
FROM [Nashville_Housing ]
ORDER BY ParcelID;

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Nashville_Housing ] A INNER JOIN 
    [Nashville_Housing ] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Nashville_Housing ] A INNER JOIN 
    [Nashville_Housing ] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM [Nashville_Housing ]

SELECT 
      SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address, 
	  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM [Nashville_Housing ]


ALTER TABLE [Nashville_Housing ]
ADD PropertySplitAddress VARCHAR(255);

UPDATE [Nashville_Housing ]
SET PropertySplitAddress   = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);


ALTER TABLE [Nashville_Housing ]
ADD PropertySplitCity  VARCHAR(255);

UPDATE [Nashville_Housing ]
SET PropertySplitCity   = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
      PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [Nashville_Housing ];

-- Breaking out Address into Individual Columns (OwnerSplitAddress)
ALTER TABLE [Nashville_Housing ]
Add OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville_Housing ]
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


-- Breaking out Address into Individual Columns (OwnerSplitCity)
ALTER TABLE [Nashville_Housing ]
Add OwnerSplitCity  Nvarchar(255);

UPDATE [Nashville_Housing ]
SET OwnerSplitCity  =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);


-- Breaking out Address into Individual Columns (OwnerSplitState)
ALTER TABLE [Nashville_Housing ]
Add OwnerSplitState   Nvarchar(255);

UPDATE [Nashville_Housing ]
SET OwnerSplitState   =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT TOP 1000 *
FROM [Nashville_Housing ];

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville_Housing ]
GROUP BY SoldAsVacant;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Nashville_Housing ];

UPDATE [Nashville_Housing ]
SET SoldAsVacant = CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates

WITH RowNumberCTE AS(SELECT *,
RANK() OVER (PARTITION BY ParcelID,
						SalePrice,
						PropertySplitAddress,
                  LegalReference
				 ORDER BY
					UniqueID
					)RowNumber
FROM [Nashville_Housing ])
SELECT * 
FROM RowNumberCTE
WHERE RowNumber > 1


-- Delete Unused Columns

ALTER TABLE [Nashville_Housing ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT TOP 1000 *
FROM [Nashville_Housing ]

