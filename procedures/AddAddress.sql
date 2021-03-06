create procedure AddAddress (
	@CityName varchar(50),
	@PostalCode char(6),
	@Street varchar(50),
	@Number int
)
as
declare @AddedAddressID as int
begin transaction
	set nocount on

	Declare @CityID as int
	select @CityID = CityID
	from Cities 
	where CityName = @CityName

	begin try
	--inserting Address
		insert into Addresses
		(
			CityID,
			PostalCode,
			Street,
			Number
		)
		values
		(
			@CityID,
			@PostalCode,
			@Street,
			@Number
		)
	end try
	begin catch
		rollback transaction;
		declare @errorMsg nvarchar(2048)
			= 'Cannot add Address. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg, 1
	end catch
	select @AddedAddressID = AddressID
	from Addresses
	where @CityID = CityID and @PostalCode = PostalCode and @Street = Street and @Number = Number
commit transaction
return @AddedAddressID