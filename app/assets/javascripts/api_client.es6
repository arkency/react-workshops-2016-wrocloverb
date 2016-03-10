const { fetch } = window;

function APIClient () {
  const JSONAPIFetch = (method, url, options) => {
    const headersOptions = {
      headers: {
        'Accept': 'application/vnd.api+json',
        'Content-Type': 'application/vnd.api+json'
      }
    };

    return fetch(url, Object.assign({}, options, headersOptions));
  };

  return {
    get (url) {
      const request = JSONAPIFetch("GET", url, {});
      return request.then(response => response.json());
    },
    post (url, params) {
      const request = JSONAPIFetch("POST", url,
                        { body: JSON.stringify(params) });
      return request.then(response => response.json());
    },
    delete (url) {
      const request = JSONAPIFetch("DELETE", url, {});
      return request.then(response => response.json());
    }
  };
}

window.APIClient = APIClient();
