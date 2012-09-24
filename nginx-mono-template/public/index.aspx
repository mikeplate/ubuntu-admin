<%@ Page Language="C#" %>
<%@ Import Namespace="System.Reflection" %>
<!DOCTYPE html>
<script runat="server">
public void Page_Load(object src, EventArgs args) {
    Title = Request.ServerVariables["HTTP_SITE_NAME"];

    String monoVersion = "Unknown";
    Type type = Type.GetType("Mono.Runtime");
    if (type != null) {                                          
        MethodInfo displayName = type.GetMethod("GetDisplayName", BindingFlags.NonPublic | BindingFlags.Static); 
        if (displayName != null)                   
            monoVersion = displayName.Invoke(null, null).ToString();
    }

    ArrayList props = new ArrayList();
    props.Add(new { Name = "OS Version", Value = Environment.OSVersion.ToString() });
    props.Add(new { Name = "Mono Version", Value = monoVersion });
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
