const rsa_load = ScriptProperties.getProperty("rsakey");

const createJwt = ({ privateKey, expiresInMinutes, data = {} }) => {
  // Sign token using RSA with SHA-256 algorithm
  const header = {
    alg: 'RS256',
    typ: 'JWT',
  };

  const now = Date.now();
  const then = new Date(now);
  const expires = new Date(now);
  expires.setMinutes(expires.getMinutes() + expiresInMinutes);
  then.setMinutes(then.getMinutes() - 1); // allow for clock drift
  // iat = issued time, exp = expiration time
  const payload = {
    exp: Math.round(expires.getTime() / 1000),
    iat: Math.round(then / 1000),
  };
  payload["iss"] = data["iss"];

  const base64Encode = (text, json = true) => {
    const data = json ? JSON.stringify(text) : text;
    return Utilities.base64EncodeWebSafe(data).replace(/=+$/, '');
  };

  const toSign = `${base64Encode(header)}.${base64Encode(payload)}`;
  Logger.log(toSign)
  const signatureBytes = Utilities.computeRsaSha256Signature(toSign, privateKey);
  const signature = base64Encode(signatureBytes, false);
  return `${toSign}.${signature}`;
};

const generateAccessToken = () => {
  const privateKey = "-----BEGIN PRIVATE KEY-----\n" + rsa_load + "\n-----END PRIVATE KEY-----\n";
  const accessToken = createJwt({
    privateKey:privateKey,
    expiresInMinutes: 9, // expires in 9 mins
    data: {
      iss: "Iv23liuPX5Pj9k6l2kKm",
    },
  });
  Logger.log(accessToken);
  return accessToken;
};

const getGHInstallationAccessToken = () => {
  const sign_token = generateAccessToken()

  // Use JWT to request access token for editing issues
  var options_acctok = {
        "method": "POST",
        "headers": {
            "authorization": "Bearer "+ sign_token,
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28"
        },
        "contentType": "application/json",
      };

  var response_acctok = UrlFetchApp.fetch("https://api.github.com/app/installations/55005093/access_tokens", options_acctok);
  var gh_response_text  = JSON.parse(response_acctok.getContentText())
  var gh_acctok   = gh_response_text.token
  return gh_acctok
}

function updateGHFile() {
  var TOKEN         = getGHInstallationAccessToken();
  var url_list      = [
                      'https://docs.google.com/spreadsheets/d/1_v1lShEJLtAhBBZEIv8fPTVKjyBOJ-NA_cibyAXMZG8/export?format=csv&gid=1914144239',
                      'https://docs.google.com/spreadsheets/d/1_v1lShEJLtAhBBZEIv8fPTVKjyBOJ-NA_cibyAXMZG8/export?format=csv&gid=379331907',
                      'https://docs.google.com/spreadsheets/d/1_v1lShEJLtAhBBZEIv8fPTVKjyBOJ-NA_cibyAXMZG8/export?format=csv&gid=9161635'
  ];

  var gh_file_list  = [
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/GIS/Mappings/gis_source.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/GIS/Mappings/gis_mapping.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/GIS/Mappings/gis_hierarchy.csv'

  ];

  var desc_list = [
                      'gis_source',
                      'gis_mapping',
                      'gis_hierarchy'
  ];

  for (var looper = 0; looper < url_list.length; looper = looper + 1) {
    var url           = url_list[looper];
    var file          = UrlFetchApp.fetch(url);
    var file_64       = Utilities.base64Encode(file.getContentText());
    var today         = Utilities.formatDate(new Date(), "GMT-4", "yyyyMMdd");
    var gh_file       = gh_file_list[looper];
    var desc          = desc_list[looper];

    var options_sha = {
          "method": "GET",
          "headers": {
              "authorization": "Bearer "+TOKEN,
              "Accept": "application/vnd.github+json",
              "X-GitHub-Api-Version": "2022-11-28"
          },
          "contentType": "application/json"
        };

    var gh_file_resp  = UrlFetchApp.fetch(gh_file, options_sha)
    var gh_file_text  = JSON.parse(gh_file_resp.getContentText())
    var gh_file_sha   = gh_file_text.sha

    Logger.log(gh_file_sha)

    var payload_pt = {
      "message": "Mapping Update: " + desc + " - " + today,
      "committer": {"name": "omop-vocab-builder[bot]", "email":"183100713+omop-vocab-builder[bot]@users.noreply.github.com"},
      "content": file_64,
      "sha": gh_file_sha
    };

    var options_pt = {
          "method": "PUT",
          "headers": {
              "authorization": "Bearer "+TOKEN,
              "Accept": "application/vnd.github+json",
              "X-GitHub-Api-Version": "2022-11-28"
          },
          "contentType": "application/json",
          "payload": JSON.stringify(payload_pt)
        };

    Logger.log(payload_pt)

    var response_pt = UrlFetchApp.fetch(gh_file, options_pt);

    Logger.log(response_pt)
  }
}
