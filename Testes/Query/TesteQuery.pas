unit TesteQuery;

interface
uses
  DUnitX.TestFramework, MegaConexao.Conexao.iMegaConexao,
  MegaConexao.Logger.iLogger, MegaConexao.SqlBuilder.iSqlBuilder,
  MegaConexao.SqlBuilder.SqlBuilderInsert;

type

  [TestFixture]
  TTesteQuery = class(TObject)
  private
    FMegaConexao : IMegaConexao;
    FLogger : ILogger;

  public

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestSQLSucess;
    [Test]
    procedure TestSQLFailed;
    [Test]
    procedure TestSQLBuilderInsertSucess;
    [Test]
    procedure TestSQLBuilderInserFailed;

  end;

implementation

uses
  MegaConexao.Conexao.ConexaoFireBird, MegaConexao.Logger.Logger,
  MegaConexao.Testes.Conexao.ConexaoSQLite, MegaConexao.Query.iQuery,
  MegaConexao.Query.MegaQuery, Data.DB, System.Generics.Collections;


{ TesteQuery }

procedure TTesteQuery.Setup;
var
 lFields : TList<TCampo>;
 lCampo: TCampo;
begin

   lFields := TList<TCampo>.Create();

   lCampo.nome := 'Id';
   lCampo.tipo := ftInteger;
   lCampo.tamanho := 0;


   lFields.Add( lcampo );


   lCampo.nome := 'Nome';
   lCampo.tipo := ftString;
   lCampo.tamanho := 100;


   lFields.Add( lcampo );



   FMegaConexao := TConexaoSqlite.Create('Tabela',lFields);
   FLogger := TLogger.Create;
end;

procedure TTesteQuery.TearDown;
var
 p : Pointer;
begin
   if FMegaConexao <> nil then begin
     p := Pointer(FMegaConexao);
     Pointer(FMegaConexao) := nil;
     iMegaConexao(p)._Release;
   end;

    if FLogger <> nil then begin
     p := Pointer(FLogger);
     Pointer(FLogger) := nil;
     ILogger(p)._Release;
   end;

end;

procedure TTesteQuery.TestSQLBuilderInserFailed;
var
  lQuery : IQuery;
  comando : string;
  lSqlBuilder : iSqlBuilder;
begin
  lSqlBuilder := TSqlBuilderInsert.Create;
  lSqlBuilder.Add('id',1)
              .Add('sobrenome','outro teste')
              .Tabela('tabela');
  lQuery := TMegaQuery.create(FMegaConexao,FLogger);

  Assert.WillRaise(procedure()
                    begin
                      lQuery.ExecuteSql(lSqlBuilder)
                    end);
end;

procedure TTesteQuery.TestSQLBuilderInsertSucess;
var
  lQuery : IQuery;
  comando : string;
  lSqlBuilder : iSqlBuilder;
begin
  lSqlBuilder := TSqlBuilderInsert.Create;
  lSqlBuilder.Add('id',1)
             .Add('nome','Teste')
             .Tabela('tabela');

  lQuery := TMegaQuery.create(FMegaConexao,FLogger);

  lQuery.ExecuteSql(lSqlBuilder);

  Assert.IsTrue(lQuery.SQL('select * from tabela').DataSet.RecordCount > 0);
  lQuery.ExecuteSql('delete from tabela');
end;

procedure TTesteQuery.TestSQLFailed;
var
  lQuery : IQuery;
  comando : string;
begin
  lQuery := TMegaQuery.create(FMegaConexao,FLogger);
  Assert.IsFalse(lQuery.SQL('select * from tabela').DataSet.RecordCount > 0);
end;

procedure TTesteQuery.TestSQLSucess;
var
  lQuery : IQuery;
  comando : string;
begin
  lQuery := TMegaQuery.create(FMegaConexao,FLogger);
  comando := 'insert into tabela (id,nome) values(1,''teste'')';

  lQuery.ExecuteSql(comando);

  Assert.IsTrue(lQuery.SQL('select * from tabela').DataSet.RecordCount > 0);
  lQuery.ExecuteSql('delete from tabela');
end;

initialization
  TDUnitX.RegisterTestFixture(TTesteQuery);
end.
