create procedure dbo.AddConferenceEdition
	@ConferenceName varchar(50),
	@Date date,
	@NumOfDays int,
	@MaxMembers int,
	@Price money,
	@StudentDiscount float
as
begin
	if (select ConferenceID from Conferences where @ConferenceName = ConferenceName) is null
	begin
		declare @errorMsg1 nvarchar(2048)
			= 'Invalid ConferenceName';
		;Throw 52000, @errorMsg1, 1
	end

	Declare @ConferenceID as int
	select @ConferenceID = ConferenceID
	from Conferences 
	where ConferenceName = @ConferenceName

	set nocount on
	begin try
		insert into ConferenceEditions
		(
			ConferenceID,
			Date,
			NumOfDay,
			MaxMembers,
			Price,
			StudentDiscount
		)
		values
		(
			@ConferenceID,
			@Date,
			@NumOfDays,
			@MaxMembers,
			@Price,
			@StudentDiscount
		)
	end try
	begin catch
		declare @errorMsg nvarchar(2048)
			= 'Cannot add Conference. Error message: ' + ERROR_MESSAGE();
		;Throw 52000, @errorMsg, 1
	end catch
end
go