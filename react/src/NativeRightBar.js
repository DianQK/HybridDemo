import { Component } from 'react';
import PropTypes from 'prop-types';

export default class NativeRightBar extends Component {

  // shouldComponentUpdate(nextProps) {
  //   return nextProps.title !== this.props.title
  // }

  componentWillMount () {
    window.$native.rightBarClick = () => {
      this.props.onClick()
    }
  }

  componentWillUnmount () {
    // window.$native.rightBarClick = null
  }

  render () {
    window.$native.rightBarTitle = this.props.title || ''
    return null
  }
}

NativeRightBar.propTypes = {
  title: PropTypes.string
};
