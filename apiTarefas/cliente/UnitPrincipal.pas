unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Ani,
  RESTRequest4D, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  DataSet.Serialize.Adapter.RESTRequest4D, System.Rtti, FMX.Grid.Style,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Controls,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Fmx.Bind.Navigator,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.ScrollBox, FMX.Grid, FMX.Edit,
  Services.Tarefa, FMX.ListBox, FMX.DateTimeCtrls
  ;

Const
 FUser = 'juvencio';
 FSenha = '12345678';
 FBaseURL = 'http://192.168.101.9:9000';

type
  TFrmPrincipal = class(TForm)
    rectAbas: TRectangle;
    imgAba1: TImage;
    imgAba2: TImage;
    imgAdd: TImage;
    imgAba3: TImage;
    imgAba4: TImage;
    TabControl: TTabControl;
    TabLista: TTabItem;
    TabCadastro: TTabItem;
    TabPesquisa: TTabItem;
    TabItem4: TTabItem;
    rectMenu: TRectangle;
    lytMenu: TLayout;
    imgFechar: TImage;
    lbListaTarefas: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    AnimationBtn: TFloatAnimation;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    MemTable: TFDMemTable;
    Grid1: TGrid;
    BindSourceDB1: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    NavigatorBindSourceDB1: TBindNavigator;
    BindingsList1: TBindingsList;
    lbTitulo: TLabel;
    edtTitulo: TEdit;
    lineNome: TLine;
    lblDescricao: TLabel;
    edtDescricao: TEdit;
    lineSobrenome: TLine;
    Label1: TLabel;
    lbPioridade: TLabel;
    DtIni: TDateEdit;
    dtFim: TDateEdit;
    lbDtIni: TLabel;
    lbDtFim: TLabel;
    retSalvar: TRectangle;
    btnSalvar: TSpeedButton;
    retCancelar: TRectangle;
    btnCancelar: TSpeedButton;
    Rectangle3: TRectangle;
    rbTotalTarefas: TRadioButton;
    rbMediaTarefas: TRadioButton;
    rbTarefasConcluidas: TRadioButton;
    pnPesquisa: TPanel;
    cbStatus: TComboBox;
    Label4: TLabel;
    cbPrioridade: TComboBox;
    Label6: TLabel;
    edCodigo: TEdit;
    Line1: TLine;
    Rectangle1: TRectangle;
    btPesquisaTarefa: TSpeedButton;
    edTotal: TEdit;
    edConcluidas: TEdit;
    edMedia: TEdit;
    procedure imgAddClick(Sender: TObject);
    procedure AnimationBtnFinish(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure imgAba1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbListaTarefasDblClick(Sender: TObject);
    procedure rbTotalTarefasClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure imgAba2Click(Sender: TObject);
    procedure rbTarefasConcluidasClick(Sender: TObject);
    procedure rbMediaTarefasClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btPesquisaTarefaClick(Sender: TObject);
  private
    FService : TServiceTarefa;

    procedure Salvar;
    procedure Incluir;
    procedure OnDelete(const ASender: TFrame; const AId: string);
    procedure OnUpdate(const ASender: TFrame; const AId: string);


    procedure OpenMenu(open: Boolean);
    procedure MudarAba(img: TImage);
    procedure ListaTarefas;


  public

  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

 {%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.fmx}

procedure TFrmPrincipal.OpenMenu(open: Boolean);
begin
    if NOT open then  // Fechando...
        AnimationBtn.Inverse := true
    else
    begin
        AnimationBtn.Inverse := false;
        lbListaTarefas.Opacity := 0;
        Label2.Opacity := 0;
        Label3.Opacity := 0;

        rectMenu.Opacity := 0;
        rectMenu.Visible := true;
        TAnimator.AnimateFloat(rectMenu, 'Opacity', 1, 0.2);
    end;

    if TabControl.ActiveTab <> TabLista  then
      NavigatorBindSourceDB1.Visible := False
    else
       NavigatorBindSourceDB1.Visible := True;

    AnimationBtn.Start;
end;

procedure TFrmPrincipal.rbMediaTarefasClick(Sender: TObject);
begin
  edMedia.Text := '';
  try
    if rbMediaTarefas.Index <> -1 then
    begin
       FService.MediaTarefas;
       FService.mtPesquisa.First;
       edMedia.Text := FService.mtPesquisa.FieldByName('Mensagem').AsString;
    end;
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmPrincipal.rbTarefasConcluidasClick(Sender: TObject);
begin
  edConcluidas.Text := '';

  try

    if rbTarefasConcluidas.Index <> -1 then
    begin
       FService.TarefasConcluidas;
       FService.mtPesquisa.First;
       edTotal.Text := FService.mtPesquisa.FieldByName('Mensagem').AsString;
    end;

  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmPrincipal.rbTotalTarefasClick(Sender: TObject);
begin
  edTotal.Text := '';

  try
    if rbTotalTarefas.Index <> -1 then
    begin
       FService.TotalTarefas;
       FService.mtPesquisa.First;
       edTotal.Text := FService.mtPesquisa.FieldByName('Mensagem').AsString;
    end;


  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmPrincipal.AnimationBtnFinish(Sender: TObject);
begin
    if NOT AnimationBtn.Inverse then // Abrindo o menu...
    begin
        TAnimator.AnimateFloat(lbListaTarefas, 'Opacity', 1, 0.1,
                               TAnimationType.In, TInterpolationType.Circular);
        TAnimator.AnimateFloat(Label2, 'Opacity', 1, 0.4,
                               TAnimationType.In, TInterpolationType.Circular);
        TAnimator.AnimateFloat(Label3, 'Opacity', 1, 0.7,
                               TAnimationType.In, TInterpolationType.Circular);
    end
    else
    begin
        TAnimator.AnimateFloat(rectMenu, 'Opacity', 0, 0.2);
        rectMenu.Visible := false;
    end;
end;

procedure TFrmPrincipal.MudarAba(img: TImage);
begin
    imgAba1.Opacity := 0.4;
    imgAba2.Opacity := 0.4;
    imgAba3.Opacity := 0.4;
    imgAba4.Opacity := 0.4;

    img.Opacity := 1;
    TabControl.GotoVisibleTab(img.Tag);
end;

procedure TFrmPrincipal.btnCancelarClick(Sender: TObject);
begin
  TabControl.Previous();
end;

procedure TFrmPrincipal.btnSalvarClick(Sender: TObject);
begin
 Salvar;
end;

procedure TFrmPrincipal.btPesquisaTarefaClick(Sender: TObject);
begin
  if edCodigo.Text <> '' then

   //bloco que copia a estrutura da memTable e add para a pesquisa
  FService.mtCadastro.CopyDataSet(MemTable, [coStructure, coRestart {, coAppend}]);


  FService.GetByCod(edCodigo.Text);

  edtTitulo.Text := FService.mtCadastro.FieldByName('ds_titulo').AsString;
  edtDescricao.Text := FService.mtCadastro.FieldByName('ds_descricao').AsString;

  if FService.mtCadastro.FieldByName('fl_status').AsString <> '' then
     cbStatus.Items.IndexOfName(FService.mtCadastro.FieldByName('fl_status').AsString);

  if FService.mtCadastro.FieldByName('fl_prioridade') .AsString <> '' then
     cbPrioridade.Items.IndexOfName(FService.mtCadastro.FieldByName('fl_prioridade') .AsString);

  DtIni.DateTime := FService.mtCadastro.FieldByName('dt_inicio').AsDateTime;
  dtFim.DateTime := FService.mtCadastro.FieldByName('dt_fim').AsDateTime;

end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FService.Free;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FService := TServiceTarefa.Create(Self);
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    MudarAba(imgAba1);
    try
      ListaTarefas;
    except
      //aqui se o servidor não tiver sido iniciado não precisa dar erro ao listar
    end;
end;

procedure TFrmPrincipal.imgAba1Click(Sender: TObject);
begin
    NavigatorBindSourceDB1.Visible := True;
    ListaTarefas;
    MudarAba(TImage(Sender));
end;

procedure TFrmPrincipal.imgAba2Click(Sender: TObject);
begin
  Incluir;
end;

procedure TFrmPrincipal.imgAddClick(Sender: TObject);
begin
    OpenMenu(true);
end;

procedure TFrmPrincipal.imgFecharClick(Sender: TObject);
begin
    OpenMenu(false);
end;

procedure TFrmPrincipal.lbListaTarefasDblClick(Sender: TObject);
begin
    ListaTarefas;
    MudarAba(TImage(imgAba1));

end;

procedure TFrmPrincipal.ListaTarefas;
var
    Resp : IResponse;
begin
    //acesso ao servidor para retorno dos dados
    Resp := TRequest.New.BaseURL( FBaseURL)
            .Resource('/Tarefa')
            .BasicAuthentication(Fuser, FSenha)
            .Accept('application/json')
            .Adapters (TDataSetSerializeAdapter.New(MemTable))
            .Get;


    if Resp.StatusCode = 200 then
    begin
        if Resp.Content.IndexOf('Mensagem') > 0 then
            ShowMessage(Resp.StatusText);
    end
    else
        ShowMessage(Resp.StatusText);
end;


procedure TFrmPrincipal.Incluir;
begin
  edtTitulo.Text := EmptyStr;
  edtDescricao.Text := EmptyStr;
  cbStatus.ItemIndex := -1;
  cbPrioridade.ItemIndex := -1;
  TabControl.Next();
end;


procedure TFrmPrincipal.OnDelete(const ASender: TFrame; const AId: string);
begin
  try
    FService.Delete(AId);
    ASender.DisposeOf;
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmPrincipal.OnUpdate(const ASender: TFrame; const AId: string);
begin
  try

    FService.GetByCod(AId);

    edtTitulo.Text := FService.mtCadastro.FieldByName('ds_titulo').AsString;
    edtDescricao.Text := FService.mtCadastro.FieldByName('ds_descricao').AsString;

    if FService.mtCadastro.FieldByName('fl_status').AsString <> '' then
       cbStatus.Items.IndexOfName(FService.mtCadastro.FieldByName('fl_status').AsString);

    if FService.mtCadastro.FieldByName('fl_prioridade').AsString <> '' then
       cbPrioridade.Items.IndexOfName(FService.mtCadastro.FieldByName('fl_prioridade').AsString);


    DtIni.DateTime := FService.mtCadastro.FieldByName('dt_inicio').AsDateTime;
    dtFim.DateTime := FService.mtCadastro.FieldByName('dt_fim').AsDateTime;
    TabControl.Next();
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmPrincipal.Salvar;
begin
  try
     FService.mtCadastro.CopyDataSet(MemTable, [coStructure, coRestart ]);

    if (edCodigo.Text <> '') then
      FService.mtCadastro.Edit
    else
      FService.mtCadastro.Append;

      FService.mtCadastro.FieldByName('ds_titulo').AsString := edtTitulo.Text;
      FService.mtCadastro.FieldByName('ds_descricao').AsString := edtDescricao.Text;
      FService.mtCadastro.FieldByName('dt_inicio').AsDateTime := DtIni.DateTime;
      FService.mtCadastro.FieldByName('dt_fim').AsDateTime := dtFim.DateTime;

    if cbStatus.ItemIndex <> -1 then
       FService.mtCadastro.FieldByName('fl_status').AsString := cbStatus.Items[ cbStatus.ItemIndex];

    if cbPrioridade.ItemIndex <> -1 then
       FService.mtCadastro.FieldByName('fl_prioridade').AsString := cbPrioridade.Items[ cbPrioridade.ItemIndex];


    FService.mtCadastro.Post;
    FService.Salvar;
    TabControl.Previous();
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

end.
