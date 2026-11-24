*****************************************;
** SAS Scoring Code for PROC Logistic;
*****************************************;

length I_sar_flag $ 12;
label I_sar_flag = 'Into: sar_flag' ;
label U_sar_flag = 'Unnormalized Into: sar_flag' ;

label P_sar_flag1 = 'Predicted: sar_flag=1' ;
label P_sar_flag0 = 'Predicted: sar_flag=0' ;

drop _LMR_BAD;
_LMR_BAD=0;

*** Check interval variables for missing values;
if nmiss(account_age_months,pep_flag,high_risk_country_share,log_cash_deposit,
        n_cash_near_threshold,log_velocity_ratio,n_new_counterparties,
        n_intl_wires,cash_per_txn,new_account) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Generate design variables for segment;
drop _0_0 _0_2 ;
length _st7 $ 7; drop _st7;
_st7 = left(trim(put (segment, $7.)));
_0_0= 0; 
_0_2= 0; 
if _st7 = 'Private'  then do;
   _0_0 = 1;
end;
else if _st7 = 'Retail'  then do;
end;
else if _st7 = 'SME'  then do;
   _0_2 = 1;
end;
else do;
   _0_0 = .;
   _0_2 = .;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Compute Linear Predictors;
drop _LP0;
_LP0 = 0;

*** Effect: account_age_months;
_LP0 = _LP0 + (-0.00698126989322) * account_age_months;
*** Effect: pep_flag;
_LP0 = _LP0 + (2.2818582299517) * pep_flag;
*** Effect: high_risk_country_sh;
_LP0 = _LP0 + (9.23715523961527) * high_risk_country_share;
*** Effect: log_cash_deposit;
_LP0 = _LP0 + (0.20638885209496) * log_cash_deposit;
*** Effect: n_cash_near_threshol;
_LP0 = _LP0 + (1.22058924883436) * n_cash_near_threshold;
*** Effect: log_velocity_ratio;
_LP0 = _LP0 + (2.14720336427558) * log_velocity_ratio;
*** Effect: n_new_counterparties;
_LP0 = _LP0 + (0.27414746849354) * n_new_counterparties;
*** Effect: n_intl_wires;
_LP0 = _LP0 + (0.40038194857218) * n_intl_wires;
*** Effect: cash_per_txn;
_LP0 = _LP0 + (0.00016872354107) * cash_per_txn;
*** Effect: new_account;
_LP0 = _LP0 + (-0.68779513178899) * new_account;
*** Effect: segment;
_LP0 = _LP0 + (0.26227144301114) * _0_0;
_LP0 = _LP0 + (0.37005155514477) * _0_2;

*** Predicted values;
drop _MAXP _IY _P0 _P1;
_TEMP = -7.5036850623278  + _LP0;
if (_TEMP < 0) then do;
   _TEMP = exp(_TEMP);
   _P0 = _TEMP / (1 + _TEMP);
end;
else _P0 = 1 / (1 + exp(-_TEMP));
_P1 = 1.0 - _P0;
P_sar_flag1 = _P0;
_MAXP = _P0;
_IY = 1;
P_sar_flag0 = _P1;
if (_P1 >  _MAXP + 1E-8) then do;
   _MAXP = _P1;
   _IY = 2;
end;
select( _IY );
   when (1) do;
      I_sar_flag = '1' ;
      U_sar_flag = 1;
   end;
   when (2) do;
      I_sar_flag = '0' ;
      U_sar_flag = 0;
   end;
   otherwise do;
      I_sar_flag = '';
      U_sar_flag = .;
   end;
end;
_SKIP_000:
if _LMR_BAD = 1 then do;
I_sar_flag = '';
U_sar_flag = .;
P_sar_flag1 = .;
P_sar_flag0 = .;
end;
drop _TEMP;
