select *
from clientestatus;

truncate table clientestatus;

-- criar uma procedure para popular a tabela clientestatus, em duas partes, caso não exista o cliente vai ser feito o insert do cliente na tabela, caso o cliente já exista vai ser feito o update no cliente. A lógica é que se a renda do cliente for maior que 3000 a coluna ccstatus vai ser preenchida com "cliente especial" e se for menor ou igual 3000 a coluna vai ser preenchida com "cliente normal".
-- procedure do professor para checar status do cliente com base na renda
delimiter //

create procedure sp_cursorclientestatus()
begin
	declare v_codcli int default null;
    declare v_salario numeric(6,2) default 0;
    declare v_fim, v_existecliente boolean default false;
    declare v_cursorcliente cursor for 
									select clicodigo, clirendamensal
									from cliente;
	declare exit handler for not found set v_fim = true;
    
    open v_cursorcliente;
    while not v_fim do
		fetch v_cursorcliente into v_codcli, v_salario;
        set v_existecliente = (select count(*) from clientestatus
								where csclicodigo = v_codcli);
		if v_salario <= 3000 then
			if v_existecliente then
				update clientestatus set csstatus = 'CLIENTE NORMAL'
				where csclicodigo = v_codcli;
			else
				insert into clientestatus values (v_codcli, 'CLIENTE NORMAL');
			end if;
		else
			if v_existecliente then
				update clientestatus set csstatus = 'CLIENTE ESPECIAL'
				where csclicodigo = v_codcli;
			else
				insert into clientestatus values (v_codcli, 'CLIENTE ESPECIAL');
			end if;
		end if;
	end while;
    close v_cursorcliente;
end//
delimiter ;

-- executando a procedure criado
select *
from clientestatus;

select *
from cliente;

update cliente
set clirendamensal = 5000
where clicodigo = 1;

update cliente
set clirendamensal = 2900
where clicodigo = 2;

update cliente
set clirendamensal = 1500
where clicodigo = 6;

desc cliente;

insert into cliente
values (null, 'M', 1350, 'Marie Josie', 3, '9299999999', 1, current_date(), null);

insert into cliente
values (null, 'F', 3800, 'CLIENTE NOVO - CURSOS', 1, '9999-1231', 1, current_date(), null);

call sp_cursorclientestatus();

/* novo exercicio: Calcular saldo geral da conta para definir quantos de juros a pessoa vai receber, 
se o saldo for >= 1000 o juros é de 5% se for <1000 o juros é de 2% */


-- criando tabelas para exercicio

create table transacao (
trid int auto_increment,
trconta int,
trdata date,
trvalor decimal(8,2),
primary key (trid)
);

drop table juros;
create table juros(
jutrid int,
juvalor decimal(8,2),
primary key(jutrid),
foreign key (jutrid) references transacao (trid)
);

insert into transacao
values
(null, 1, '2024-03-01', 500),
(null, 1, '2024-03-02', -100),
(null, 1, '2024-03-03', 200),
(null, 2, '2024-03-01', 1000),
(null, 2, '2024-03-02', -500),
(null, 2, '2024-03-03', -100),
(null, 3, '2024-03-01', 2000),
(null, 3, '2024-03-02', -300),
(null, 3, '2024-03-04', -800),
(null, 1, '2024-03-08', 500),
(null, 1, '2024-03-09', 1000),
(null, 1, '2024-03-07', 3000);


select * from transacao;
select * from juros;

-- procedure para o exercicio do juros

drop procedure sp_calculajuros;
delimiter //

create procedure sp_calculajuros()
begin
	declare v_conta int default null;
    declare v_saldo decimal(10,2) default 0;
    declare v_juros decimal(10,2) default 0;
    declare v_fim, v_existejuros boolean default false;
    declare v_cursortransacao cursor for 
									select trconta, sum(trvalor)
									from transacao
                                    group by trconta;
	declare exit handler for not found set v_fim = true;
    
    open v_cursortransacao;
    while not v_fim do
		fetch v_cursortransacao into v_conta, v_saldo;
        set v_existejuros = (select count(*) from juros
								where jutrid = v_conta);
		if v_saldo >= 1000 then
			set v_juros = v_saldo * 1.05;
			if v_existejuros then
				update juros set juvalor = v_juros
				where jutrid = v_conta;
			else
				insert into juros values (v_conta, v_juros);
			end if;
		else
			set v_juros = v_saldo * 1.02;
			if v_existejuros then
				update juros set juvalor = v_juros
				where jutrid = v_conta;
			else
				insert into juros values (v_conta, v_juros);
			end if;
		end if;
	end while;
    close v_cursortransacao;
end//

delimiter ;


call sp_calculajuros();

