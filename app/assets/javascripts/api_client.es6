const { fetch } = window;

function APIClient () {
  const JSONAPIFetch = (method, url, options) => {
    const headersOptions = {
      method,
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
      return request;
    },
    post (url, params) {
      const request = JSONAPIFetch("POST", url,
                        { body: JSON.stringify(params) });
      return request;
    },
    delete (url) {
      const request = JSONAPIFetch("DELETE", url, {});
      return request;
    }
  };
}

window.APIClient = APIClient();
