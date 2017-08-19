// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

class Hello extends React.component {
  constructor(props) {
    super(props);
    this.state = { name: 'karl' };
  }

  changeName(e) {
    this.setState({
      name: e.target.value
    });
  }

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

Hello.defaultProps = {
  name: 'David'
};

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<Hello />, document.getElementById('hello'));
});
