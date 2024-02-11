program apiMontreal;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.BasicAuthentication,
  Model.Connection in 'Model\Model.Connection.pas',
  Controller.Tarefa in 'Controller\Controller.Tarefa.pas',
  Model.Tarefa in 'Model\Model.Tarefa.pas';

begin
    THorse.Use(Jhonson());
    //autenticação basica de acesso
    //Authorization: Basic anV2ZW5jaW86MTIzNDU2Nzg=
    THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('juvencio') and APassword.Equals('12345678');
    end));

    Controller.Tarefa.Registry;

    THorse.Listen(9000);
end.
