// This script enables a per-file commit of the resulting delta tables using the
// self-hosted runner on a public repository. It is otherwise not possible to bypass
// branch protection rules using git commands in a standard GitHub action with a
// self-hosted runner. The script is based on a Google Apps script that does the
// same for integrating collaborative GoogleSheets with the CVB repository. The commits
// are executed using the GitHub application account designated for this repository.

const crypto = require('crypto');
const fs = require('node:fs');

privateKeyEnv = process.env.PRIVATE_KEY;

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
    return Buffer.from(data).toString('base64').replace(/=+$/, '');
  };

  const toSign = `${base64Encode(header)}.${base64Encode(payload)}`;
  const sign = crypto.createSign('SHA256');
  sign.write(toSign);
  sign.end();
  const signatureBytes = sign.sign(privateKey);
  const signature = base64Encode(signatureBytes, false);
  return `${toSign}.${signature}`;
};

const generateAccessToken = () => {
  const privateKey = "-----BEGIN PRIVATE KEY-----\n" + privateKeyEnv + "\n-----END PRIVATE KEY-----\n";
  const accessToken = createJwt({
    privateKey:privateKey,
    expiresInMinutes: 9, // expires in 9 mins
    data: {
      iss: "Iv23liuPX5Pj9k6l2kKm",
    },
  });
  return accessToken;
};

async function fetchToken(options_acctok) {
    const response = await fetch("https://api.github.com/app/installations/55349543/access_tokens", options_acctok);
    const respJson = await response.json();
    return respJson ;
}

async function getGHInstallationAccessToken() {
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
  // var jsonData = fetch("https://api.github.com/app/installations/55349543/access_tokens", options_acctok).then(response=> response.json()).then(data=>{jsonData=data; return jsonData});
  const jsonData = await fetchToken(options_acctok)
  return jsonData.token;
};

async function commitFiles() {
  var TOKEN  = await getGHInstallationAccessToken();
  var local_files   = [
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/concept_ancestor_delta.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/concept_class_delta.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/concept_delta.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/concept_relationship_delta.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/concept_synonym_delta.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/domain_delta.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/mapping_metadata.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/relationship_delta.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/restore.sql',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/source_to_concept_map.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/update_log.csv',
                      '/tmp/runner/CVB/CVB/PSYCHIATRY/Ontology/vocabulary_delta.csv'
  ];

  var gh_file_list  = [
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/concept_ancestor_delta.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/concept_class_delta.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/concept_delta.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/concept_relationship_delta.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/concept_synonym_delta.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/domain_delta.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/mapping_metadata.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/relationship_delta.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/restore.sql',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/source_to_concept_map.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/update_log.csv',
                      'https://api.github.com/repos/TuftsCTSI/CVB/contents/PSYCHIATRY/Ontology/vocabulary_delta.csv'
  ];

  var desc_list = [
                      'concept_ancestor_delta',
                      'concept_class_delta',
                      'concept_delta',
                      'concept_relationship_delta',
                      'concept_synonym_delta',
                      'domain_delta',
                      'mapping_metadata',
                      'relationship_delta',
                      'restore.sql',
                      'source_to_concept_map',
                      'update_log',
                      'vocabulary_delta'
  ];

  for (var looper = 0; looper < local_files.length; looper = looper + 1) {
    var file          = fs.readFileSync(local_files[looper], 'utf8');
    var file_64       = Buffer.from(file).toString('base64');
    var today_def     = new Date();
    const pad         = (i) => (i < 10) ? "0" + i : "" + i;
    var today         = today_def.getFullYear() + pad(1 + today_def.getMonth()) + pad(today_def.getDate());
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

    var gh_file_resp  = await fetch(gh_file, options_sha)
    var gh_file_text  = await gh_file_resp.json();
    var gh_file_sha   = await gh_file_text.sha

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
          //"payload": JSON.stringify(payload_pt)
          "body": JSON.stringify(payload_pt)
        };


    var response_pt = await fetch(gh_file, options_pt);
    var response_json = await response_pt.json();

    console.log(response_json);
  }

}

commitFiles()