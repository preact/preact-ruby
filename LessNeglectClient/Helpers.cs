/*
 * Copyright 2011 Christopher Gooley / LessNeglect.com
 *
 * Author(s):
 *  Christopher Gooley / LessNeglect (gooley@lessneglect.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
using System.Net;
using System.Web;
using System.Security.Cryptography;

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;

namespace LessNeglect
{
    internal static class Helpers
    {
        private static string user_agent = "LessNeglect Client .NET v0.1.0";

        public static byte[] GetPostData(List<KeyValuePair<string, string>> items)
        {
            string postData = "";
            List<string> vals = new List<string>();
            foreach (var item in items)
            {
                vals.Add(string.Format("{0}={1}", HttpUtility.UrlEncode(item.Key), HttpUtility.UrlEncode(item.Value)));
            }
            postData = string.Join("&", vals.ToArray());

            ASCIIEncoding encoding = new ASCIIEncoding();
            return encoding.GetBytes(postData);
        }

        public static JObject GetApiResponse(string url, string method, JObject obj)
        {
            List<KeyValuePair<string, string>> items = new List<KeyValuePair<string, string>>();

            foreach (var v in obj.Properties())
            {
                items.Add(new KeyValuePair<string, string>(v.Name, v.Value.ToString()));
            }

            return GetApiResponse(url, method, items);
        }

        // POST or PUT or something
        public static JObject GetApiResponse(string url, string method, List<KeyValuePair<string, string>> items)
        {
            // notify the server that we've got a file to (maybe) upload
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);
            req.Method = method;
            req.Accept = "text/javascript";
            req.UserAgent = user_agent;

            var data = GetPostData(items);

            req.ContentType = "application/x-www-form-urlencoded";
            req.ContentLength = data.Length;
            Stream newStream = req.GetRequestStream();
            // Send the data.
            newStream.Write(data, 0, data.Length);
            newStream.Close();

            Stream streamResponse;

            // grab the response
            try
            {
                HttpWebResponse response = (HttpWebResponse)req.GetResponse();
                streamResponse = response.GetResponseStream();
            }
            catch (HttpException ex)
            {
                switch (ex.GetHttpCode())
                {
                    case 400:
                        {
                            throw new HttpException(400, "API Requests must be signed. Refer to the documentation.");
                        }
                    case 403:
                        {
                            throw new HttpException(403, "Invalid request signature. Confirm you signed it correctly with the correct project_code and secret");
                        }
                    default:
                        throw ex;
                }
            }

            if (streamResponse != null)
            {
                // And read it out
                StreamReader reader = new StreamReader(streamResponse);
                string body = reader.ReadToEnd();
                body = body.Trim("[]".ToCharArray());
                return JObject.Parse(body);
            }
            else
            {
                return null;
            }
        }

        // GET
        public static JObject GetApiResponse(string url)
        {
            // notify the server that we've got a file to (maybe) upload
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);
            req.Method = "GET";
            req.Accept = "text/javascript";
            req.UserAgent = user_agent;

            // grab the response
            HttpWebResponse response = (HttpWebResponse)req.GetResponse();
            Stream streamResponse = response.GetResponseStream();

            // And read it out
            StreamReader reader = new StreamReader(streamResponse);
            string body = reader.ReadToEnd();
            body = body.Trim("[]".ToCharArray());
            return JObject.Parse(body);
        }
    }
}
