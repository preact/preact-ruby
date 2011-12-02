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

using System.Security.Cryptography;

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;

namespace LessNeglect
{
    [JsonObject(MemberSerialization.OptIn)]
    public class CoreRequest
    {
        [JsonProperty(PropertyName = "project_code")]
        public string ProjectCode { get; set; }

        [JsonProperty(PropertyName = "timestamp")]
        public string Timestamp { get; set; }

        [JsonProperty(PropertyName = "token")]
        public string Token { get; set; }

        [JsonProperty(PropertyName = "signature")]
        public string Signature { get; set; }

        public void SignRequest(string code, string key)
        {
            ProjectCode = code;
            Timestamp = DateTime.Now.Ticks.ToString();
            Token = Guid.NewGuid().ToString("N");

            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
            byte[] keyByte = encoding.GetBytes(key);
            HMACSHA256 hmacsha256 = new HMACSHA256(keyByte);

            byte[] messageBytes = encoding.GetBytes(string.Format("{0}{1}", Timestamp, Token));
            byte[] hashmessage = hmacsha256.ComputeHash(messageBytes);

            Signature = ByteToString(hashmessage).ToLower();
        }

        private static string ByteToString(byte[] buff)
        {
            string sbinary = "";

            for (int i = 0; i < buff.Length; i++)
            {
                sbinary += buff[i].ToString("X2"); // hex format
            }
            return (sbinary);
        }
    }
}
