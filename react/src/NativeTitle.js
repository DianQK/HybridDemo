import { Component } from 'react';
import PropTypes from 'prop-types';

export default class NativeTitle extends Component {

  // shouldComponentUpdate(nextProps) {
  //   return nextProps.title !== this.props.title
  // }

  render() {
    window.$native.title = this.props.title || ''
    return null
  }
}

NativeTitle.propTypes = {
  title: PropTypes.string
};
