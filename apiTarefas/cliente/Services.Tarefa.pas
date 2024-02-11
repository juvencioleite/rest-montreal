unit Services.Tarefa;

interface

uses

  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  RESTRequest4D,
  RESTRequest4D.Request.Client, DataSet.Serialize, DataSet.Serialize.Adapter.RESTRequest4D,
  System.JSON;

Const
 FUser = 'juvencio';
 FSenha = '12345678';
 FBaseURL = 'http://192.168.101.9:9000';


Type
  TServiceTarefa = class(TDataModule)
    mtCadastro: TFDMemTable;
    mtPesquisa: TFDMemTable;
    mtPesquisaMENSAGEM: TStringField;
    procedure DataModuleCreate(Sender: TObject);
  public
    procedure Salvar;
    procedure Listar;
    procedure Delete(const ACod: string);
    procedure GetByCod(const ACod: string);
    function TotalTarefas : String;
    function TarefasConcluidas : String;
    function MediaTarefas : String;
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TServiceTarefa.DataModuleCreate(Sender: TObject);
begin
//  mtCadastro.Open;
//  mtPesquisa.Open;
end;

procedure TServiceTarefa.Delete(const ACod: string);
var
  LResponse: IResponse;
begin
  LResponse := TRequest.New
    .BaseURL(FBaseURL)
    .Resource('Tarefa/DeleteTarefa')
    .Accept('application/json')
    .ResourceSuffix(ACod)
    .Delete;
  if not (LResponse.StatusCode = 204) then
    raise Exception.Create(LResponse.JSONValue.GetValue<string>('Mensagem'));
end;

procedure TServiceTarefa.GetByCod(const ACod: string);
var
  LResponse: IResponse;
begin
  //caso tenha sido preenchido e não passado pela limpeza de dados
  try
    mtCadastro.EmptyDataSet;
  except

  end;
  LResponse := TRequest.New
    .BaseURL(FBaseURL)
    .Resource('Tarefa/ListarTarefaCD')
    .BasicAuthentication(Fuser, FSenha)
    .Accept('application/json')
    .ResourceSuffix(ACod)
    .Adapters(TDataSetSerializeAdapter.New(mtCadastro))
    .Get;
  if not (LResponse.StatusCode = 200) then
    raise Exception.Create(LResponse.JSONValue.GetValue<string>('Mensagem'));
end;

procedure TServiceTarefa.Listar;
var
  LResponse: IResponse;
begin
  LResponse := TRequest.New
    .BaseURL(FBaseURL)
    .Resource('Tarefa')
    .BasicAuthentication(Fuser, FSenha)
    .Accept('application/json')
    .Adapters (TDataSetSerializeAdapter.New(mtPesquisa))
    .Get;
  if not (LResponse.StatusCode = 200) then
    raise Exception.Create(LResponse.JSONValue.GetValue<string>('Mensagem'));
end;

function TServiceTarefa.MediaTarefas : string;
var
    Resp : IResponse;
begin
    Result := 'Nenhum valor encontrado';
    //acesso ao servidor para retorno dos dados
    Resp := TRequest.New.BaseURL( FBaseURL)
            .Resource('/Tarefa/MediaTarefas')
            .BasicAuthentication(Fuser, FSenha)
            .Accept('application/json')
            .Adapters (TDataSetSerializeAdapter.New(mtPesquisa))
            .Get;

    if Resp.StatusCode = 200 then
        Result := mtPesquisa.fields[0].AsString
    else
      raise Exception.Create(Resp.StatusText);
end;


procedure TServiceTarefa.Salvar;
  var
   Frecurso : String;
   LRequest: IRequest;
   LResponse: IResponse;

begin

  Frecurso := '/Tarefa/AddTarefa';
  if mtCadastro.FieldByName('cd_tarefa').AsString <> '' then
    Frecurso := '/Tarefa/EditarTarefa/:cod';

  LRequest := TRequest.New
    .BaseURL(FBaseURL)
    .Resource(Frecurso)
    .BasicAuthentication(Fuser, FSenha)
    .ContentType('application/json')
    .Accept('application/json')
    .AddBody(mtCadastro.ToJSONObject);
  if (mtCadastro.FieldByName('cd_tarefa').AsInteger > 0) then
    LResponse := LRequest.ResourceSuffix(mtCadastro.FieldByName('cd_tarefa').AsString).Put
  else
    LResponse := LRequest.Post;
  if not (LResponse.StatusCode in [201, 204]) then
    raise Exception.Create(LResponse.JSONValue.GetValue<string>('Mensagem'));
  mtCadastro.EmptyDataSet;
end;

function TServiceTarefa.TarefasConcluidas : string;
var
    Resp : IResponse;
begin

    Result := 'Nenhum valor encontrado';
    //acesso ao servidor para retorno dos dados
    Resp := TRequest.New.BaseURL( FBaseURL)
            .Resource('/Tarefa/TarefasConcluidas')
            .BasicAuthentication(Fuser, FSenha)
            .Accept('application/json')
            .Adapters (TDataSetSerializeAdapter.New(mtPesquisa))
            .Get;

    if Resp.StatusCode = 200 then
        Result := mtPesquisa.fields[0].AsString
    else
      raise Exception.Create(Resp.StatusText);
end;


function TServiceTarefa.TotalTarefas : String;
var
    Resp : IResponse;
begin

    Result := 'Nenhum valor encontrado';
    //acesso ao servidor para retorno dos dados
    Resp := TRequest.New.BaseURL( FBaseURL)
            .Resource('/Tarefa/TotalTarefas')
            .BasicAuthentication(Fuser, FSenha)
            .Accept('application/json')
            .Adapters (TDataSetSerializeAdapter.New(mtPesquisa))
            .Get;

    if Resp.StatusCode = 200 then
        Result := mtPesquisa.fields[0].AsString
    else
      raise Exception.Create(Resp.StatusText);
end;



end.
