class Protoboard {
  static async api() {
    const response = await fetch('/config/environment.json');
    const environment = await response.json();
    return `http://${environment.PROTOBOARD_API_ADDRESS}`;
  }

  static async download_link_from_glimpse(glimpse) {
    const params = new URLSearchParams({
      hash: glimpse.knowledge_hash,
      scope: glimpse.scope,
      model: glimpse.model
    });

    const url = new URL(`${await Protoboard.api()}/knowledges/download`);
    url.search = params.toString();

    return url.toString();
  }

  static async download_link(knowledge) {
    const params = new URLSearchParams({
      hash: knowledge.hash,
      scope: knowledge.scope,
      model: knowledge.model
    });

    const url = new URL(`${await Protoboard.api()}/knowledges/download`);
    url.search = params.toString();

    return url.toString();
  }

  static async delete(path, params) {
    const headers = {
      'Content-Type': 'application/json'
    };

    if (params === undefined) params = {};

    const url = new URL(`${await Protoboard.api()}${path}`);
    url.search = new URLSearchParams(params).toString();

    const response = await fetch(url, {
      headers: headers,
      method: 'DELETE'
    });

    if (response.status !== 200) {
      return { error: true };
    } else {
      return { success: await response.json() };
    }
  }

  static async post(path, params) {
    const headers = {
      'Content-Type': 'application/json'
    };

    const response = await fetch(`${await Protoboard.api()}${path}`, {
      headers: headers,
      method: 'POST',
      body: JSON.stringify(params)
    });

    if (response.status !== 200) {
      return { error: true };
    } else {
      return { success: await response.json() };
    }
  }

  static async get(path, params) {
    const headers = {
      'Content-Type': 'application/json'
    };

    if (params === undefined) params = {};

    const url = new URL(`${await Protoboard.api()}${path}`);
    url.search = new URLSearchParams(params).toString();

    try {
      const response = await fetch(url, {
        headers: headers,
        method: 'GET'
      });

      if (response.status !== 200) {
        return { error: true };
      } else {
        return { success: await response.json() };
      }
    } catch (error) {
      return { error: error.message };
    }
  }

  static async overviewEstimateTokens(params) {
    const headers = {
      'Content-Type': 'application/json'
    };

    const response = await fetch(`${await Protoboard.api()}/tokens/estimate/overview`, {
      headers: headers,
      method: 'POST',
      body: JSON.stringify(params)
    });

    if (response.status !== 200) {
      return { error: true };
    } else {
      return { success: await response.json() };
    }
  }

  static async estimateTokens(file, index) {
    const formData = new FormData();

    formData.append('file', file, file.name);

    const response = await fetch(`${await Protoboard.api()}/tokens/estimate`, {
      method: 'POST',
      body: formData
    });

    if (response.status !== 200) {
      return { error: true, index: index };
    } else {
      let result = await response.json();
      result['index'] = index;
      return { success: result };
    }
  }

  static async uploadKnowledge(scope, file) {
    const formData = new FormData();

    formData.append('file', file, file.name);
    formData.append('scope', scope);

    const response = await fetch(`${await Protoboard.api()}/knowledges`, {
      method: 'POST',
      body: formData
    });

    if (response.status !== 200) {
      return { error: true };
    } else {
      return { success: await response.json() };
    }
  }

  static async sendMessage(chatId, message) {
    const headers = {
      'Content-Type': 'application/json'
    };

    const payload = {
      verbose: true,
      message: message
    };

    const response = await fetch(`${await Protoboard.api()}/chats/${chatId}`, {
      method: 'POST',
      headers: headers,
      body: JSON.stringify(payload)
    });

    if (response.status !== 200) {
      return { error: true };
    } else {
      return { success: await response.json() };
    }
  }

  static async models() {
    const response = await fetch(`${await Protoboard.api()}/models`);

    if (response.status !== 200) {
      return { error: true };
    } else {
      return { success: await response.json() };
    }
  }

  static async chats() {
    const response = await fetch(`${await Protoboard.api()}/chats`);

    if (response.status !== 200) {
      return { error: true };
    } else {
      return { success: await response.json() };
    }
  }

  static async chat(id) {
    const response = await fetch(`${await Protoboard.api()}/chats/${id}?verbose=true`);

    if (!response.ok) {
      return { error: true };
    } else {
      const data = await response.json();

      return { success: data, error: !data };
    }
  }
}

export default Protoboard;
