
<%@page import="javax.print.attribute.standard.Finishings"%><%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.*,PluSoft.Utils.*,java.lang.reflect.*"%>
<% 		
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");	
	 
    String methodName = request.getParameter("method");
           
    try{
	    Class[] argsClass = new Class[2]; 
	    argsClass[0] = HttpServletRequest.class;
	    argsClass[1] = HttpServletResponse.class;
	    
	    Class cls = this.getClass();   
	    Method method = cls.getMethod(methodName, argsClass);   
	    
	    Object[] args = new Object[2];
	    args[0] = request;
	    args[1] = response;   
	    
	    BeforeInvoke(methodName);
	    method.invoke(this, args);     
    }catch( Exception e){
        HashMap result = new HashMap();
        result.put("error", -1);
        result.put("message", e.getMessage());
        result.put("stackTrace", e.getStackTrace());
        String json = PluSoft.Utils.JSON.Encode(result);
        response.reset();
        response.getWriter().write(json);
    }        
    finally
    {
        AfterInvoke(methodName);
    }
%>
<%!
//权限管理
protected void BeforeInvoke(String methodName)
{
    //Hashtable user = GetUser();
    //if (user.role == "admin" && methodName == "remove") throw .      
}
//日志管理
protected void AfterInvoke(String methodName)
{
	
}
//////////////////////////////////////
public void SearchEmployees(HttpServletRequest request, HttpServletResponse response) throws Exception
{ 		
    //查询条件
    String key = request.getParameter("key");
    //分页
    int pageIndex = Convert.toInt(request.getParameter("pageIndex"));
    int pageSize = Convert.toInt(request.getParameter("pageSize"));        
    //字段排序
    String sortField = request.getParameter("sortField");
    String sortOrder = request.getParameter("sortOrder");
    
    HashMap result = new Test.TestDB().SearchEmployees(key, pageIndex, pageSize, sortField, sortOrder);
    String json = PluSoft.Utils.JSON.Encode(result);
    response.getWriter().write(json);
}
public void SaveEmployees(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String employeesStr = request.getParameter("employees");
    ArrayList employees = (ArrayList)PluSoft.Utils.JSON.Decode(employeesStr);

    for(int i=0,l=employees.size(); i<l; i++){
    	HashMap employee = (HashMap)employees.get(i);
  		
        if (employee.get("id") == null || employee.get("id").toString().equals(""))
        {
            employee.put("createtime", new Date());
            new Test.TestDB().InsertEmployee(employee);
        }
        else
        {
            new Test.TestDB().UpdateEmployee(employee);
        }
    }
}
public void RemoveEmployees(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String idStr = request.getParameter("id");       
    if (StringUtil.isNullOrEmpty(idStr)) return;
    String[] ids = idStr.split(",");
    for (int i = 0, l = ids.length; i < l; i++)
    {
        String id = ids[i]; 
        new Test.TestDB().DeleteEmployee(id);
    }    
}
public void GetEmployee(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String id = request.getParameter("id");
    HashMap user = new Test.TestDB().GetEmployee(id);
    String json = PluSoft.Utils.JSON.Encode(user);
    response.getWriter().write(json);
}
public void GetDepartments(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    ArrayList data = new Test.TestDB().GetDepartments();
    String json = PluSoft.Utils.JSON.Encode(data);
    response.getWriter().write(json);
}
public void GetPositions(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    ArrayList data = new Test.TestDB().GetPositions();
    String json = PluSoft.Utils.JSON.Encode(data);
    response.getWriter().write(json);
}
public void GetEducationals(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    ArrayList data = new Test.TestDB().GetEducationals();
    String json = PluSoft.Utils.JSON.Encode(data);
    response.getWriter().write(json);
}
public void GetPositionsByDepartmenId(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String id = request.getParameter("id");
    ArrayList data = new Test.TestDB().GetPositionsByDepartmenId(id);
    String json = PluSoft.Utils.JSON.Encode(data);
    response.getWriter().write(json);
}

public void GetDepartmentEmployees(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String dept_id = request.getParameter("dept_id");
    int pageIndex = Convert.toInt(request.getParameter("pageIndex"));
    int pageSize = Convert.toInt(request.getParameter("pageSize"));

    HashMap result = new Test.TestDB().GetDepartmentEmployees(dept_id, pageIndex, pageSize);
    String json = PluSoft.Utils.JSON.Encode(result);
    response.getWriter().write(json);
}


public void SaveDepartment(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String departmentsStr = request.getParameter("departments");
    
    ArrayList departments = (ArrayList)PluSoft.Utils.JSON.Decode(departmentsStr);
    
    for(int i=0,l=departments.size(); i<l; i++){
    	HashMap d = (HashMap)departments.get(i);  		
    	new Test.TestDB().UpdateDepartment(d);
    }
}

/////////////////////////////
public void FilterCountrys(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String key = request.getParameter("key");
    String value = request.getParameter("value");
	
    //建立value的快速哈希索引，便于快速判断是否已经选择
    String[] values = value.split(",");
    HashMap valueMap = new HashMap();
    for(int i=0,l=values.length; i<l; i++){
        String id = values[i];
        valueMap.put(id, true);
    }

    //获取数据 
    String path = request.getSession().getServletContext().getRealPath("/");    
    
    
    String file = path + "/demo/data/countrys.txt";
    String s = PluSoft.Utils.File.read(file);
    ArrayList data = (ArrayList)PluSoft.Utils.JSON.Decode(s);

    //1）去除已经选择的记录
    for (int i = data.size() - 1; i >= 0; i--)
    {
        HashMap o = (HashMap)data.get(i);
        String id = o.get("id").toString();
        if (valueMap.get(id) != null)
        {
            data.remove(i);
        }
    }


    //2）根据名称查找
    ArrayList result = new ArrayList();
    for (int i = 0, l = data.size(); i < l; i++)
    {
        HashMap o = (HashMap)data.get(i);
        String text = o.get("text").toString();
        if (StringUtil.isNullOrEmpty(key) || text.toLowerCase().indexOf(key.toLowerCase()) != -1)
        {
            result.add(o);
        }
    }

    //返回JSON数据
    String json = PluSoft.Utils.JSON.Encode(result);
    response.getWriter().write(json);
}
public void FilterCountrys2(HttpServletRequest request, HttpServletResponse response) throws Exception
{
    String key = request.getParameter("key");
    String value = request.getParameter("value");
	
    //获取数据 
    String path = request.getSession().getServletContext().getRealPath("/");    
    
    
    String file = path + "/demo/data/countrys.txt";
    String s = PluSoft.Utils.File.read(file);
    ArrayList data = (ArrayList)PluSoft.Utils.JSON.Decode(s);


    //根据名称查找
    ArrayList result = new ArrayList();
    for (int i = 0, l = data.size(); i < l; i++)
    {
        HashMap o = (HashMap)data.get(i);
        String text = o.get("text").toString();
        if (StringUtil.isNullOrEmpty(key) || text.toLowerCase().indexOf(key.toLowerCase()) != -1)
        {
            result.add(o);
        }
    }

    //返回JSON数据
    String json = PluSoft.Utils.JSON.Encode(result);
    response.getWriter().write(json);
}
%> 