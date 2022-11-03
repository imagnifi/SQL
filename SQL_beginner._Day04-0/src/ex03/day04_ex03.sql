SELECT generated_date missing_date FROM v_generated_dates
EXCEPT
SELECT visit_date missing_date FROM person_visits
ORDER BY missing_date







