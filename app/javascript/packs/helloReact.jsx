// @flow

import React, { Component } from 'react';
import { render } from 'react-dom';

class Hello extends Component {
  state = { name: '0' };

  changeName = event => {
    this.setState({
      name: event.target.value
    });
  };

  render() {
    return (
      <div>
        <form>
          <input onChange={this.changeName} value={this.state.name} />
        </form>
        Hello {this.state.name}!
      </div>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  render(<Hello />, document.getElementById('app'));
});

export default Hello; // we need this export for flow checking.
