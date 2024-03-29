unit Controller.Tarefa;

interface

uses Horse, System.JSON, System.SysUtils, Model.Tarefa,
     FireDAC.Comp.Client, Data.DB, DataSet.Serialize, System.DateUtils;

procedure Registry;

implementation

procedure ListarTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    qry : TFDQuery;
    erro : string;
    arrayTarefas : TJSONArray;
begin
    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco')).Status(500);
        exit;
    end;

    try
      try
        qry := tarefa.ListarTarefas('', erro);

          arrayTarefas := qry.ToJSONArray();

          res.Send<TJSONArray>(arrayTarefas);
      except
          res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', 'Erro ao acessar tabela ' + erro))).Status(500);
          exit;
      end;

    finally
        qry.Free;
        tarefa.Free;
    end;
end;

procedure ListarTarefaCD(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefas: TJSONObject;
    qry : TFDQuery;
    erro : string;
    Fcod : Integer;
begin
    writeln('Listando tarefa...');
    writeln('Conexao com o banco...');

    try
        tarefa := TTarefa.Create;
        //tarefa.cd_tarefa := Req.Params['Cod'].ToInteger;
    except
        res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco')) ).Status(500);
        exit;
    end;

    try
        FCod := Req.Params['Cod'].ToInteger;
        qry := tarefa.PesquisaTarefa(Fcod.ToString , erro);

        if qry.RecordCount > 0 then
        begin
            objTarefas := qry.ToJSONObject;
            res.Send<TJSONObject>(objTarefas)
        end
        else
           res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', 'Tarefa n�o encontrada'))).Status(404);
    finally
        qry.Free;
        tarefa.Free;
    end;
end;

procedure TotalTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefas: TJSONObject;
    qry : TFDQuery;
    erro : string;
begin
    writeln('total de tarefas...');
    writeln('Conexao com o banco...');

    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco')).Status(500);
        exit;
    end;

    try
        qry := tarefa.ListarTarefas('', erro);

        if qry.RecordCount > 0 then
        begin
          res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', IntToStr(qry.RecordCount))));
        end
        else
            res.Send(TJsonPair.create('Mensagem',  'N�o existem tarefas')).Status(404);
    finally
        qry.Free;
        tarefa.Free;
    end;
end;


procedure TarefasConcluidas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefas: TJSONObject;
    resultado : Integer;
    erro : string;
begin
    writeln('total de tarefas concluidas');
    writeln('Conexao com o banco...');

    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco') ).Status(500);
        exit;
    end;

    try
        resultado := tarefa.qtdTarefasConcluidas( erro);

        if resultado > 0 then
        begin
          res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', IntToStr(resultado))));
        end
        else
            res.Send(TJsonPair.create('Mensagem', 'N�o existem tarefas') ).Status(404);
    finally
        tarefa.Free;
    end;
end;

procedure MediaTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefas: TJSONObject;
    resultado : Integer;
    erro : string;
begin
    writeln('Media de tarefas ');
    writeln('Conexao com o banco...');

    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco')).Status(500);
        exit;
    end;

    try
        resultado := tarefa.mediaTarefasNConcluidas( erro);

        if resultado > 0 then
        begin
          res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', IntToStr(resultado))));
        end
        else
            res.Send(TJsonPair.create('Mensagem', 'N�o existem tarefas') ).Status(404);
    finally
        tarefa.Free;
    end;
end;


procedure AddTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefa: TJSONObject;
    fDataI,
    fDataF,
    erro : string;
    body  : TJsonValue;



begin
    // Conexao com o banco...
    writeln('Inserindo tarefa...');
    writeln('Conexao com o banco...');

    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco') ).Status(500);
        exit;
    end;
    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            tarefa.ds_titulo := body.GetValue<string>('dsTitulo', '');
            tarefa.ds_descricao := body.GetValue<string>('dsDescricao', '');
            tarefa.fl_status := body.GetValue<string>('flStatus', '');
            tarefa.fl_prioridade := body.GetValue<string>('flPrioridade', '');
            fDataI :=  body.GetValue<string>('dtInicio');
            fDataF := body.GetValue<string>('dtFim');
            tarefa.dt_inicio := System.SysUtils.StrToDateTime (fDataI);
            tarefa.dt_fim := System.SysUtils.StrToDateTime(fDataF);

            tarefa.Inserir(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                writeln('erro' + ex.Message);
                res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', erro))).Status(400);
                exit;
            end;
        end;


        objTarefa := TJSONObject.Create;
        objTarefa.AddPair('cd_tarefa', tarefa.cd_tarefa.ToString);

        res.Send<TJSONObject>(objTarefa).Status(201);
    finally
        tarefa.Free;
    end;
end;

procedure DeleteTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefa: TJSONObject;
    erro : string;
begin
    // Conexao com o banco...
    writeln('Apagando tarefa...');
    writeln('Conexao com o banco...');

    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco') ).Status(500);
        exit;
    end;

    try
        try
            tarefa.cd_tarefa := Req.Params['Cod'].ToInteger;

            if NOT tarefa.Excluir(erro) then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                writeln('erro' + ex.Message);
                res.Send(TJsonPair.create('Mensagem', 'Erro ao exlcuir registro' + ex.Message )  ).Status(400);
                exit;
            end;
        end;


        objTarefa := TJSONObject.Create;
        objTarefa.AddPair('cd_tarefa', tarefa.cd_tarefa.ToString);

        res.Send<TJSONObject>(objTarefa);
    finally
        tarefa.Free;
    end;
end;

procedure EditarTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefa: TJSONObject;
    erro : string;
    body : TJsonValue;
begin
    // Conexao com o banco...
    writeln('Editando tarefa...');
    writeln('Conexao com o banco...');
    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco')).Status(500);
        exit;
    end;

    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;
            tarefa.cd_tarefa := body.GetValue<integer>('cdTarefa', 0);
            tarefa.ds_titulo := body.GetValue<string>('dsTitulo', '');
            tarefa.ds_descricao := body.GetValue<string>('dsDescricao', '');
            tarefa.fl_status := body.GetValue<string>('flStatus', '');
            tarefa.fl_prioridade := body.GetValue<string>('flPrioridade', '');
            tarefa.dt_inicio := body.GetValue<TDateTime>('dtInicio', now);
            tarefa.dt_fim := body.GetValue<TDateTime>('dtFim', now);

            tarefa.Editar(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', erro))).Status(400);
                writeln('erro' + ex.Message);
                exit;
            end;
        end;


        objTarefa := TJSONObject.Create;
        objTarefa.AddPair('cd_tarefa', tarefa.cd_tarefa.ToString);

        res.Send<TJSONObject>(objTarefa).Status(200);
    finally
        tarefa.Free;
    end;
end;

procedure EditarStatusTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    tarefa : TTarefa;
    objTarefa: TJSONObject;
    erro : string;
    body : TJsonValue;
begin
    // Conexao com o banco...
    writeln('Editando status tarefa...');
    writeln('Conexao com o banco...');
    try
        tarefa := TTarefa.Create;
    except
        res.Send(TJsonPair.create('Mensagem', 'Erro ao conectar com o banco')).Status(500);
        exit;
    end;

    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            tarefa.fl_status := body.GetValue<string>('flStatus', '');
            tarefa.dt_fim := body.GetValue<TDateTime>('dtFim', now);

            tarefa.Editar(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(TJSONObject.Create(TJsonPair.create('Mensagem', erro))).Status(400);
                writeln('erro' + ex.Message);
                exit;
            end;
        end;


        objTarefa := TJSONObject.Create;
        objTarefa.AddPair('cd_tarefa', tarefa.cd_tarefa.ToString);

        res.Send<TJSONObject>(objTarefa).Status(200);
    finally
        tarefa.Free;
    end;
end;



procedure Registry;
begin
    THorse.Get('/Tarefa', ListarTarefas);
    THorse.Get('/Tarefa/ListarTarefaCD/:Cod', ListarTarefaCD);

    THorse.Get('/Tarefa/TotalTarefas', TotalTarefas);
    THorse.Get('/Tarefa/TarefasConcluidas', TarefasConcluidas);
    THorse.Get('/Tarefa/MediaTarefas', MediaTarefas);
    THorse.Post('/Tarefa/AddTarefa', AddTarefa);
    THorse.Put('/Tarefa/EditarTarefa/:Cod', EditarTarefa);
    THorse.Put('/Tarefa/EditarStatusTarefa/:Cod', EditarStatusTarefa);
    THorse.Delete('/Tarefa/DeleteTarefa/:Cod', DeleteTarefa);

end;

end.
