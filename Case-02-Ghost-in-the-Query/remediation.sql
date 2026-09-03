-- Step 1: Confirm the scope of the compromised account's grant
SHOW GRANTS FOR 'jdoe_frontend'@'%';

-- Step 2: Revoke the excessive, unscoped grant
REVOKE ALL PRIVILEGES ON *.* FROM 'jdoe_frontend'@'%';

-- Step 3: Apply a least-privilege scope matching the account's actual role
GRANT SELECT ON app_frontend.* TO 'jdoe_frontend'@'%';
FLUSH PRIVILEGES;

-- Step 4: Fleet-wide audit — find every account with the same blanket grant
SELECT grantee, privilege_type
FROM information_schema.user_privileges
WHERE privilege_type = 'ALL PRIVILEGES' AND grantee != "'root'@'localhost'";

-- Step 5: Re-scope each account found above on a case-by-case basis
-- (repeat Steps 2-3 per account, matching each role's actual requirements)
