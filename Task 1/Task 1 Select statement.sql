SELECT OwnerID, OwnerLastName, OwnerFirstName, (case when ownerphone is null then ''
													else ownerphone end) OwnerPhone, OwnerEmail
FROM PET_OWNER

SELECT PetID, PetName, PetType, (case when petbreed is null then 'Unknown'
									  else petbreed end) PetBreed, format(petdob, 'dd-MMM-yy') as PetDOB, OwnerID
FROM PET
