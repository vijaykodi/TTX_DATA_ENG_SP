/****** Object:  StoredProcedure [dbo].[s_Key_Change]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************
*	Written by Joshua Bronte			*
*	03/27/2008					*
*	HPS Key Changes					*
*							*
********************************************************/

CREATE          PROC [dbo].[s_Key_Change] (@Update INT = 0, @Carrier CHAR(2) = NULL)

AS

--DECLARE 	@Carrier AS CHAR(2)
--SET		@Carrier  = 'EC'

IF 		@Update = 1 

BEGIN

UPDATE		dbo.KeyChanges 
SET		CarrierID = @Carrier
WHERE		CarrierID IS NULL

END

--claimbase
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber
		, t2.ec_pa_id_name = LEFT(r1.firstname, 6)

FROM 		dbo.claimbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimbase sex
UPDATE 		t2

SET 		 t2.cl_pa_sex = cpe.PA_SEX
	
FROM 		dbo.claimbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

INNER JOIN	dbo.ClaimBasePatientEligibility cpe
ON		r1.CarrierID = cpe.PA_CI_ID
AND		r1.membernumber = cpe.PA_ID

WHERE		cpe.PA_LAST_UPD_REL_LVL = (SELECT MAX(PA_LAST_UPD_REL_LVL)FROM ClaimBasePatientEligibility
					   WHERE r1.CarrierID = PA_CI_ID
					AND	r1.membernumber = PA_ID)
AND 		isnull(r1.firstname,'') = left(isnull(PA_Name,''),LEN(LTRIM(isnull(r1.firstname,''))))


--claimpatient
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimpatient t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId


--ClaimPatient Name Change, Sex

UPDATE 		t2

SET 		t2.ec_pa_name = cpe.pa_name
		, t2.ec_pa_sex = cpe.PA_SEX
FROM 		dbo.claimpatient t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

INNER JOIN	dbo.ClaimBasePatientEligibility cpe
ON		r1.CarrierID = cpe.PA_CI_ID
AND		r1.membernumber = cpe.PA_ID

WHERE		isnull(r1.firstname,'') = left(isnull(PA_Name,''),LEN(LTRIM(isnull(r1.firstname,''))))

--claimdisabilityficparmdet
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilityficparmdet t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilityitem
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilityitem t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilitylastclaim
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilitylastclaim t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilitylet
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilitylet t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilityoverride
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilityoverride t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilityparm
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilityparm t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilityperiod
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilityperiod t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilitytotalstatus
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilitytotalstatus t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisallow
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisallow t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId



--claimexternalbase
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimexternalbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimexternaldesc
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimexternaldesc t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimexternalitem
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimexternalitem t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimexternalcounter
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimexternalcounter t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimexternaldescfiller
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimexternaldescfiller t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimfiller
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimfiller t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimhospital
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimhospital t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimhospitalub
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimhospitalub t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimindicator
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimindicator t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

WHERE 		t2.ec_cl_id + t2.ec_cl_gen+t2.ec_ci_id+t2.ec_sys_id 
		NOT IN(SELECT ec_cl_id + ec_cl_gen+ec_ci_id+ec_sys_id
			FROM 		dbo.claimindicator t2

			INNER JOIN	dbo.KeyChanges r1
			ON		t2.ec_ci_id = r1.CarrierID
			AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
			AND 		t2.ec_sys_id = r1.SystemId	
			AND		t2.ec_pa_rel = r1.relationship
			AND		t2.ec_pa_id = r1.membernumber)
--claimletter
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimletter t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimmedbase
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimmedbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimletterdata
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimletterdata t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimmeddet
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimmeddet t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

WHERE 		t2.ec_cl_id + t2.ec_cl_gen+t2.ec_ci_id+t2.ec_sys_id 
		NOT IN(SELECT ec_cl_id + ec_cl_gen+ec_ci_id+ec_sys_id
			FROM 		dbo.claimmeddet t2

			INNER JOIN	dbo.KeyChanges r1
			ON		t2.ec_ci_id = r1.CarrierID
			AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
			AND 		t2.ec_sys_id = r1.SystemId	
			AND		t2.ec_pa_rel = r1.relationship
			AND		t2.ec_pa_id = r1.membernumber)
--claimmember
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimmember t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId


--claimpatientfiller
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimpatientfiller t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimoverride
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimoverride t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimpatientcob
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimpatientcob t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimplandata
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimplandata t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimspecialty
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimspecialty t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--dentalproviderplandetail
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.dentalproviderplandetail t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--dentalproviderbase
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.dentalproviderbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--disabilityproviderbase
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.disabilityproviderbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--medicalproviderbase
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.medicalproviderbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimadmission
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimadmission t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimadmissiondesc
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimadmissiondesc t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

WHERE 		t2.ec_cl_id + t2.ec_cl_gen+t2.ec_ci_id+t2.ec_sys_id 
		NOT IN(SELECT ec_cl_id + ec_cl_gen+ec_ci_id+ec_sys_id
			FROM 		dbo.claimadmissiondesc t2

			INNER JOIN	dbo.KeyChanges r1
			ON		t2.ec_ci_id = r1.CarrierID
			AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
			AND 		t2.ec_sys_id = r1.SystemId	
			AND		t2.ec_pa_rel = r1.relationship
			AND		t2.ec_pa_id = r1.membernumber)
--claimadmissionfiller
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimadmissionfiller t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimalternatepayee
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimalternatepayee t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimcheck
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimcheck t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdentalbase
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdentalbase t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimcustom
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimcustom t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdentaldet
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdentaldet t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilitybenexpl
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilitybenexpl t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

--claimdisabilityficaparm
UPDATE 		t2

SET 		t2.ec_pa_rel = r1.relationship
		, t2.ec_pa_id = r1.membernumber

FROM 		dbo.claimdisabilityficaparm t2

INNER JOIN	dbo.KeyChanges r1
ON		t2.ec_ci_id = r1.CarrierID
AND		t2.ec_cl_id + t2.ec_cl_gen = r1.claimnumber
AND 		t2.ec_sys_id = r1.SystemId

GO
