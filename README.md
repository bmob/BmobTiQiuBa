# BmobTiQiuBa
踢球吧源码开放

## 项目文件说明

- web：踢球吧web端代码
- iOS：iOS的代码
- cloudcode：踢球吧云端代码，使用里面的文件名作为bmob后台的云端代码名，把文件的内容粘贴到云端代码

### web项目的部署

假设项目的路径为/var/www/BmobTiQiuBa

nginx的配置文件如下：

```
server
	{
		listen       80;
		server_name local.tq;
		 index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/BmobTiQiuBa

		location / {  
   			 if (!-e $request_filename){  
		        	rewrite ^/(.*) /index.php last;  
		    	 }  
		}  
                location ~ .*\.(php|php5)?$
                        {
                                fastcgi_pass  unix:/tmp/php-cgi.sock;
                                fastcgi_index index.php;
                                include fastcgi_params;
                                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                                fastcgi_param PATH_INFO $fastcgi_script_name;
                        }

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
                        {
                                expires      30d;
                        }

                location ~ .*\.(js|css)?$
                        {
                                expires      12h;
                        }

		access_log  /home/wwwlogs/access.log  access;
	}
```

把web/protected/config/param.php文件中的配置替换：

```
	'inviteMsgUrl' => 'http://www.jianzhou.sh.cn/JianzhouSMSWSServer/httpsendPersonalMessages',  //发送短信的api服务的url
	'MsgUsername' => 'your account',    //发送短信的api服务的账号
	'MsgPwd' => 'your pwd',				//发送短信的api服务的密码

	'baiduPushUrl' => 'http://channel.api.duapp.com/rest/2.0/channel/channel',
	'baiduPushApiKey' => 'your baidu api key',   //百度推送的api key
	'baiduPushSecretKey' => 'your baidu secret key',  //百度推送的secret key
```

把web/protectedcomponents/BmobSdk文件中的配置替换：

```
    const APPID = 'Application ID';  //后台"应用密钥"中的Application ID
    const RESTKEY = 'REST API Key';  //后台"应用密钥"中的REST API Key
```

### 云端代码的部署

把cloudcode/getMsgCode.txt文件中的配置替换为申请的accout和pwd：

```
http.post('http://www.jianzhou.sh.cn/JianzhouSMSWSServer/http/sendPersonalMessages', {form:{'account':'your account','password':'your pwd','destMobiles':mobile,'msgContents':'sms'}});
```

把cloudcode/commentScore.txt和userGoalAssist.txt文件中的master key替换为bmob中用户所申请的master key：

```
 db.setHeader({"X-Bmob-Master-Key":"your master key"});
```