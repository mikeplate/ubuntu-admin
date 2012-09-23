<%@ Page Language="C#" %>
<!DOCTYPE html>
<script runat="server">
protected String Title;

public void Page_Load(object src, EventArgs args) {
    Title = Request.ServerVariables["HTTP_SITE_NAME"];

    ArrayList props = new ArrayList();
    props.Add(new { Name = "ASP.NET Version", Value = Environment.Version.ToString() });

    Properties.DataSource = props;
    Properties.DataBind();
}
</script>
<html>
    <head>
        <title><%=Title%></title>
        <link rel="stylesheet" type="text/css" href="/status.css" />
    </head>
    <body>
        <h1><%=Title%></h1>
        <table>
        <asp:Repeater ID="Properties" runat="server">
            <ItemTemplate>
                <tr>
                    <td nowrap><%# Eval("Name") %></td>
                    <td><%# Eval("Value") %></td>
                </tr>
            </ItemTemplate>
        </asp:Repeater>
        </table>
    </body>
</html>
