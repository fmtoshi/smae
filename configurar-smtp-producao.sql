-- ============================================
-- SMAE - Configurar SMTP de Producao
-- Prefeitura de Itapevi
-- ============================================

-- Atualiza configuracao de SMTP para producao
UPDATE emaildb_config 
SET config = jsonb_set(
    config, 
    '{sender,args}', 
    '{
        "host": "mail.mudtech.com.br", 
        "port": 465, 
        "ssl": 1, 
        "sasl_username": "sistema@mudtech.com.br", 
        "sasl_password": "*EbJ8;14^541"
    }'::jsonb
) 
WHERE id = (SELECT id FROM public.emaildb_config WHERE ativo = true ORDER BY id LIMIT 1);

-- Verifica a configuracao
SELECT id, config->'sender'->'args' as smtp_config FROM emaildb_config WHERE ativo = true;

