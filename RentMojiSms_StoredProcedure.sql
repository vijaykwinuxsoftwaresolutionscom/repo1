--exec Dashboard
CREATE PROCEDURE Dashboard @DashboardPageSize integer = 10
AS
WITH cteTenent AS
(
   SELECT *,
         ROW_NUMBER() OVER (PARTITION BY MessageGroupId ORDER BY CreatedOn DESC) AS rn
		 FROM USHomeag_RM.dbo.SMSLogs
		 where MessageGroupId is not NULL 
		 and MessageType in('Email','InboundSMS')
),
cteUnknownNumber AS
(
		SELECT *, '' as rn 
		FROM USHomeag_RM.dbo.SMSLogs 
		where MessageType = 'InboundSMSFromUnknownNumber' 
)

select top (select @DashboardPageSize) *
from 
(select Id,SenderMobile,SenderName,RecieverMobile,RecieverName,SenderEmail,RecieverEmail,TextSMS,
MessageType,MessageId,UserId,IsDelivered,MessageCreatedOn,CreatedOn,MessageGroupId,IsReplied
from cteTenent where rn = 1
union
select Id,SenderMobile,SenderName,RecieverMobile,RecieverName,SenderEmail,RecieverEmail,TextSMS,
MessageType,MessageId,UserId,IsDelivered,MessageCreatedOn,CreatedOn,MessageGroupId,IsReplied
from cteUnknownNumber
) as recordUnion
ORDER BY CreatedOn DESC

go 

--exec ChatMessages 'cbengtson@ushomeag.com'
CREATE PROCEDURE ChatMessages 
@TenantEmail nvarchar(250) 
AS
WITH cteTenent AS
(
   SELECT *,
         ROW_NUMBER() OVER (PARTITION BY MessageGroupId ORDER BY CreatedOn DESC) AS rn
		 FROM USHomeag_RM.dbo.SMSLogs
		 where MessageGroupId is not NULL 
		 and MessageType in('Email','InboundSMS')
		 and SenderEmail = @TenantEmail
		 and (IsReplied is null or IsReplied = 0)
),
cteAdmin AS
(
		SELECT *, '' as rn FROM USHomeag_RM.dbo.SMSLogs 
		where MessageType = 'OutboundSMS' 
		and RecieverEmail = @TenantEmail
)

select Id,SenderMobile,SenderName,RecieverMobile,RecieverName,SenderEmail,RecieverEmail,TextSMS,
MessageType,MessageId,UserId,IsDelivered,MessageCreatedOn,CreatedOn,MessageGroupId,IsReplied
from cteTenent where rn = 1
union
select Id,SenderMobile,SenderName,RecieverMobile,RecieverName,SenderEmail,RecieverEmail,TextSMS,
MessageType,MessageId,UserId,IsDelivered,MessageCreatedOn,CreatedOn,MessageGroupId,IsReplied
from cteAdmin
ORDER BY CreatedOn
